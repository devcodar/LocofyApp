'use client';
const colors: Record<string, string> = {
  pago: 'bg-green-500',
  atrasado: 'bg-red-500',
  pendente: 'bg-yellow-500',
};
export function StatusBadge({ status }: { status: string }) {
  const color = colors[status] ?? 'bg-gray-500';
  return <span className={`px-2 py-1 rounded text-white ${color}`}>{status}</span>;
}
