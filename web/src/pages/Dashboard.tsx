import { Link } from 'react-router-dom'
import { LinkButton } from '../components/Button'
import { StatusBadge } from '../components/StatusBadge'

const mockDraws = [
  {
    id: 'FL-24001',
    amount: '$25,000',
    term: '6 mo',
    status: 'Funded' as const,
    updated: 'Apr 2, 2026',
  },
  {
    id: 'FL-24002',
    amount: '$12,500',
    term: '3 mo',
    status: 'Processing' as const,
    updated: 'Apr 10, 2026',
  },
]

function statusVariant(s: (typeof mockDraws)[0]['status']) {
  if (s === 'Funded') return 'success'
  if (s === 'Processing') return 'processing'
  return 'neutral'
}

export function Dashboard() {
  return (
    <div className="mx-auto max-w-6xl space-y-8">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-flexline-navy">Dashboard</h1>
          <p className="mt-1 text-sm text-flexline-muted">
            View your facility, request draws, and track repayments.
          </p>
        </div>
        <LinkButton to="/request-draw">
          Request draw <span aria-hidden>›</span>
        </LinkButton>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <section className="rounded-xl border border-flexline-border bg-white p-5 shadow-card lg:col-span-2">
          <h2 className="text-sm font-semibold text-flexline-navy">
            Available credit
          </h2>
          <div className="mt-4 flex flex-wrap items-center gap-8">
            <div
              className="relative grid h-28 w-28 place-items-center rounded-full"
              style={{
                background:
                  'conic-gradient(#2BB673 0deg 210deg, #e3eef6 210deg 360deg)',
              }}
              aria-hidden
            >
              <div className="absolute inset-2 grid place-items-center rounded-full bg-white text-center text-xs font-semibold text-flexline-navy shadow-inner">
                <div>
                  <div className="text-lg leading-tight">$87.5k</div>
                  <div className="text-[10px] font-normal text-flexline-muted">
                    of $150k
                  </div>
                </div>
              </div>
            </div>
            <div className="min-w-0 flex-1 space-y-2 text-sm">
              <div className="flex justify-between gap-4">
                <span className="text-flexline-muted">Utilized</span>
                <span className="font-semibold text-flexline-navy">$62,500</span>
              </div>
              <div className="flex justify-between gap-4">
                <span className="text-flexline-muted">Available</span>
                <span className="font-semibold text-flexline-green">$87,500</span>
              </div>
              <Link
                to="/repayments"
                className="inline-block pt-2 text-sm font-semibold text-flexline-green hover:underline"
              >
                View repayment schedule ›
              </Link>
            </div>
          </div>
        </section>

        <section className="rounded-xl border border-sky-100 bg-sky-50/80 p-5 shadow-card">
          <div className="flex items-start gap-3">
            <div className="rounded-lg bg-white p-2 text-flexline-navy shadow-sm">
              <svg className="h-5 w-5" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
                <path d="M12 22a2 2 0 002-2H10a2 2 0 002 2zm6-6V11a6 6 0 10-12 0v5l-2 2v1h16v-1l-2-2z" />
              </svg>
            </div>
            <div>
              <h2 className="text-sm font-semibold text-flexline-navy">
                Notifications
              </h2>
              <p className="mt-2 text-xs leading-relaxed text-flexline-muted">
                Your recent notifications will appear here.
              </p>
            </div>
          </div>
        </section>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <section className="rounded-xl border border-flexline-border bg-white p-5 shadow-card">
          <h2 className="text-sm font-semibold text-flexline-navy">Bank accounts</h2>
          <p className="mt-1 text-xs text-flexline-muted">
            Add and verify accounts for disbursement.
          </p>
          <LinkButton
            to="/bank-accounts"
            variant="secondary"
            className="mt-4 inline-flex"
          >
            Manage bank accounts ›
          </LinkButton>
        </section>
        <section className="rounded-xl border border-flexline-border bg-white p-5 shadow-card">
          <h2 className="text-sm font-semibold text-flexline-navy">Repayments</h2>
          <p className="mt-1 text-xs text-flexline-muted">
            See instalments, due dates, and statuses (demo data).
          </p>
          <LinkButton
            to="/repayments"
            variant="secondary"
            className="mt-4 inline-flex"
          >
            Open repayments ›
          </LinkButton>
        </section>
      </div>

      <section className="overflow-hidden rounded-xl border border-flexline-border bg-white shadow-card">
        <div className="border-b border-flexline-border bg-flexline-table-head px-4 py-3">
          <h2 className="text-sm font-semibold text-flexline-navy">Recent draws</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead>
              <tr className="border-b border-flexline-border bg-flexline-table-head text-xs font-semibold uppercase tracking-wide text-flexline-navy">
                <th className="px-4 py-3">Draw ID</th>
                <th className="px-4 py-3">Amount</th>
                <th className="px-4 py-3">Term</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Last updated</th>
                <th className="px-4 py-3 text-right">Action</th>
              </tr>
            </thead>
            <tbody>
              {mockDraws.map((row) => (
                <tr
                  key={row.id}
                  className="border-b border-flexline-border last:border-0"
                >
                  <td className="px-4 py-3 font-semibold text-flexline-navy">
                    {row.id}
                  </td>
                  <td className="px-4 py-3">{row.amount}</td>
                  <td className="px-4 py-3">{row.term}</td>
                  <td className="px-4 py-3">
                    <StatusBadge variant={statusVariant(row.status)}>
                      {row.status}
                    </StatusBadge>
                  </td>
                  <td className="px-4 py-3 text-flexline-muted">{row.updated}</td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      to="/request-draw"
                      className="text-sm font-semibold text-flexline-green hover:underline"
                    >
                      View ›
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  )
}
