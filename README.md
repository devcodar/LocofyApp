# Condo SaaS

MVP de sistema de gestão condominial usando Next.js e Supabase.

## Setup

1. Crie projeto no [Supabase](https://supabase.com) e execute `supabase/sql/supabase_schema_mvp.sql`.
2. Copie `.env.example` para `.env` e preencha as chaves do Supabase, Resend e Firebase.
3. Instale dependências: `npm install`.
4. Rode em desenvolvimento: `npm run dev`.
5. Execute testes: `npm test`.

Usuários demo são inseridos via `scripts/seed.ts`.

Fase 2 inclui integração de visão computacional em `/kiosk` e pagamentos.
