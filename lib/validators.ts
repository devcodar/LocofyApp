import { z } from 'zod';

export const reservaSchema = z.object({
  recurso_id: z.string().uuid(),
  inicio: z.string(),
  fim: z.string(),
});

export function hasOverlap(
  inicio: Date,
  fim: Date,
  existentes: { inicio: Date; fim: Date }[]
): boolean {
  return existentes.some(r => inicio < r.fim && fim > r.inicio);
}
