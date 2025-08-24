'use client';
interface Column<T> { key: keyof T; header: string; }
interface DataTableProps<T> { data: T[]; columns: Column<T>[]; }
export function DataTable<T>({ data, columns }: DataTableProps<T>) {
  return (
    <table className="min-w-full text-sm">
      <thead>
        <tr>
          {columns.map(c => (
            <th key={String(c.key)} className="px-2 py-1 text-left">
              {c.header}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row, i) => (
          <tr key={i}>
            {columns.map(c => (
              <td key={String(c.key)} className="px-2 py-1">
                {String(row[c.key])}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
