'use client';
import { ReactNode } from 'react';

interface Props {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
}
export function DrawerForm({ open, onClose, children }: Props) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 bg-black/50">
      <div className="absolute right-0 top-0 h-full w-80 bg-white p-4 shadow">
        <button onClick={onClose} className="mb-2">Fechar</button>
        {children}
      </div>
    </div>
  );
}
