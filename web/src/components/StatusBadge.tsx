type Variant = 'neutral' | 'pending' | 'success' | 'processing'

const styles: Record<Variant, string> = {
  neutral:
    'border border-sky-200 bg-sky-50 text-flexline-navy',
  pending:
    'border border-amber-200 bg-flexline-pending text-flexline-pending-text',
  success: 'border border-emerald-200 bg-emerald-50 text-emerald-900',
  processing: 'border border-violet-200 bg-violet-50 text-violet-900',
}

export function StatusBadge({
  children,
  variant = 'neutral',
}: {
  children: React.ReactNode
  variant?: Variant
}) {
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${styles[variant]}`}
    >
      {children}
    </span>
  )
}
