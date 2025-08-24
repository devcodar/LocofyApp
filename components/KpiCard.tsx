'use client';
interface Props { title: string; value: string | number; }
export function KpiCard({ title, value }: Props) {
  return (
    <div className="p-4 border rounded">
      <p className="text-sm text-gray-500">{title}</p>
      <p className="text-2xl font-bold">{value}</p>
    </div>
  );
}
