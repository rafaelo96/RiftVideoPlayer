export default function Loading() {
  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-[var(--color-paper)]">
      <div className="flex flex-col items-center gap-4">
        <div className="w-8 h-8 rounded-full border-2 border-[var(--color-rule)] border-t-[var(--color-accent)] animate-spin" />
        <p className="text-sm font-medium text-[var(--color-muted)]">Loading Rift…</p>
      </div>
    </div>
  );
}
