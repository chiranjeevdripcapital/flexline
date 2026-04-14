import { Button } from '../components/Button'
import { StatusBadge } from '../components/StatusBadge'

const accounts = [
  {
    id: '1',
    label: 'Operating · JPM · ···4421',
    status: 'Verified' as const,
  },
  {
    id: '2',
    label: 'Payroll · BoA · ···8890',
    status: 'Pending' as const,
  },
]

export function BankAccounts() {
  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-flexline-navy">Bank accounts</h1>
        <p className="mt-1 text-sm text-flexline-muted">
          Verified accounts can be used for draw disbursement. Micro-deposit or
          Plaid verification flows will connect here in a later milestone.
        </p>
      </div>

      <section className="rounded-xl border border-flexline-border bg-white p-5 shadow-card">
        <div className="flex items-center justify-between gap-4">
          <h2 className="text-sm font-semibold text-flexline-navy">Your accounts</h2>
          <Button type="button">Add bank account</Button>
        </div>
        <ul className="mt-4 divide-y divide-flexline-border rounded-lg border border-flexline-border">
          {accounts.map((a) => (
            <li
              key={a.id}
              className="flex flex-wrap items-center justify-between gap-3 px-4 py-3"
            >
              <span className="text-sm font-medium text-flexline-navy">{a.label}</span>
              <StatusBadge
                variant={a.status === 'Verified' ? 'success' : 'pending'}
              >
                {a.status === 'Pending' ? 'Pending verification' : a.status}
              </StatusBadge>
            </li>
          ))}
        </ul>
      </section>

      <section className="rounded-xl border border-sky-100 bg-sky-50/60 p-4 text-sm text-flexline-muted">
        <strong className="text-flexline-navy">MVP note:</strong> ACH debit
        authorization and e-sign are tracked in the PRD but not wired in this
        scaffold.
      </section>
    </div>
  )
}
