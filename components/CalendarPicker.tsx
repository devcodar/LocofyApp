'use client';
export function CalendarPicker({ value, onChange }: { value?: string; onChange?: (v: string) => void }) {
  return <input type="date" value={value} onChange={e => onChange?.(e.target.value)} />;
}
