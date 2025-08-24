-- (Cole aqui o DDL completo com RLS e policies.)
-- Utilize o schema fornecido a seguir (baseado no design aprovado):

create extension if not exists "pgcrypto";  -- gen_random_uuid()
create extension if not exists "uuid-ossp";
set time zone 'UTC';

create table if not exists public.condominios (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cnpj text,
  criado_em timestamptz not null default now()
);

create table if not exists public.usuarios (
  id uuid primary key,
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  unidade_id uuid,
  nome text,
  email text unique,
  role text not null check (role in ('morador','sindico','porteiro','admin')),
  criado_em timestamptz not null default now()
);

create table if not exists public.blocos (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  nome text not null
);

create table if not exists public.unidades (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  bloco_id uuid references public.blocos(id) on delete set null,
  numero text not null,
  morador_id uuid references public.usuarios(id) on delete set null
);

create table if not exists public.avisos (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  titulo text not null,
  conteudo text not null,
  visivel_ate date,
  criado_por uuid references public.usuarios(id),
  criado_em timestamptz not null default now()
);

create table if not exists public.recursos (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  nome text not null,
  tipo text not null check (tipo in ('salao','churrasqueira','academia','outro')),
  regras jsonb not null default '{}'::jsonb
);

create table if not exists public.reservas (
  id uuid primary key default gen_random_uuid(),
  recurso_id uuid not null references public.recursos(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  inicio timestamptz not null,
  fim timestamptz not null,
  status text not null check (status in ('pendente','aprovada','rejeitada','cancelada')) default 'pendente',
  observacoes text,
  criado_por uuid references public.usuarios(id),
  criado_em timestamptz not null default now()
);

create table if not exists public.solicitacoes (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  tipo text not null check (tipo in ('reclamacao','manutencao','convivencia','outro')),
  descricao text,
  status text not null check (status in ('aberta','em_analise','em_andamento','resolvida','cancelada')) default 'aberta',
  sla_dias int not null default 7,
  anexo_url text,
  criado_por uuid references public.usuarios(id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.cobrancas (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  tipo text not null check (tipo in ('taxa','multa','tarifa')),
  descricao text,
  valor numeric(12,2) not null,
  vencimento date not null,
  status text not null check (status in ('pendente','pago','atrasado','cancelado')) default 'pendente',
  comprovante_url text,
  criado_por uuid references public.usuarios(id),
  criado_em timestamptz not null default now()
);

create table if not exists public.correspondencias (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  tipo text not null check (tipo in ('carta','encomenda','volume')),
  status text not null check (status in ('disponivel','retirada','extraviada')) default 'disponivel',
  recebido_em timestamptz not null default now(),
  retirado_em timestamptz,
  registrado_por uuid references public.usuarios(id),
  confirmado_por uuid references public.usuarios(id)
);

create table if not exists public.eventos_visao (
  id uuid primary key default gen_random_uuid(),
  condominio_id uuid not null references public.condominios(id) on delete cascade,
  tipo text not null check (tipo in ('pessoas','vagas','fila','aglomeracao')),
  local text,
  contagem int,
  metadata jsonb not null default '{}'::jsonb,
  criado_em timestamptz not null default now()
);

create table if not exists public.audit_log (
  id bigserial primary key,
  condominio_id uuid,
  usuario_id uuid,
  acao text,
  objeto text,
  payload jsonb,
  criado_em timestamptz not null default now()
);

create or replace function public.tg_touch_atualizado_em()
returns trigger language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end$$;

create or replace trigger trg_touch_solicitacoes
before update on public.solicitacoes
for each row execute function public.tg_touch_atualizado_em();

-- RLS habilitada
alter table public.condominios enable row level security;
alter table public.usuarios enable row level security;
alter table public.blocos enable row level security;
alter table public.unidades enable row level security;
alter table public.avisos enable row level security;
alter table public.recursos enable row level security;
alter table public.reservas enable row level security;
alter table public.solicitacoes enable row level security;
alter table public.cobrancas enable row level security;
alter table public.correspondencias enable row level security;
alter table public.eventos_visao enable row level security;
alter table public.audit_log enable row level security;

-- Policies (amostra representativa; replique padrão)
create policy reservas_select on public.reservas for select
using (exists (select 1 from public.usuarios u where u.id = auth.uid() and u.condominio_id = reservas.condominio_id));
create policy reservas_insert on public.reservas for insert
with check (exists (select 1 from public.usuarios u where u.id = auth.uid() and u.condominio_id = reservas.condominio_id and (u.role in ('sindico','admin') or u.unidade_id = reservas.unidade_id)));
create policy cobrancas_select on public.cobrancas for select
using (exists (select 1 from public.usuarios u where u.id = auth.uid() and u.condominio_id = cobrancas.condominio_id));
create policy cobrancas_modify on public.cobrancas for all
using (exists (select 1 from public.usuarios u where u.id = auth.uid() and u.condominio_id = cobrancas.condominio_id and u.role in ('sindico','admin')))
with check (exists (select 1 from public.usuarios u where u.id = auth.uid() and u.condominio_id = cobrancas.condominio_id and u.role in ('sindico','admin')));
-- (Inclua policies equivalentes para avisos, recursos, solicitacoes, correspondencias, usuarios, blocos, unidades, eventos_visao, audit_log)

-- STORAGE
select storage.create_bucket('anexos', public => false);
alter table storage.objects enable row level security;
create policy storage_read_condo on storage.objects for select using (
  bucket_id = 'anexos' and exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.condominio_id::text = split_part(storage.objects.name, '/', 1)
  )
);
create policy storage_write_condo on storage.objects for insert with check (
  bucket_id = 'anexos' and exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.condominio_id::text = split_part(storage.objects.name, '/', 1)
  )
);
create policy storage_admin_modify on storage.objects for all using (
  bucket_id = 'anexos' and exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.condominio_id::text = split_part(storage.objects.name, '/', 1) and u.role in ('sindico','admin')
  )
) with check (
  bucket_id = 'anexos' and exists (
    select 1 from public.usuarios u
    where u.id = auth.uid() and u.condominio_id::text = split_part(storage.objects.name, '/', 1) and u.role in ('sindico','admin')
  )
);
