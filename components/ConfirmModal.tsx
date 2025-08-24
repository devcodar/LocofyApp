'use client';
interface Props {
  open: boolean;
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
}
export function ConfirmModal({ open, message, onConfirm, onCancel }: Props) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/50">
      <div className="bg-white p-4 rounded">
        <p>{message}</p>
        <div className="mt-2 flex gap-2">
          <button onClick={onConfirm} className="px-2 py-1 bg-green-600 text-white rounded">OK</button>
          <button onClick={onCancel} className="px-2 py-1 bg-gray-300 rounded">Cancelar</button>
        </div>
      </div>
    </div>
  );
}
