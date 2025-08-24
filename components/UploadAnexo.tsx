'use client';
export function UploadAnexo({ onFile }: { onFile?: (file: File) => void }) {
  return (
    <input
      type="file"
      onChange={e => {
        const file = e.target.files?.[0];
        if (file && onFile) onFile(file);
      }}
    />
  );
}
