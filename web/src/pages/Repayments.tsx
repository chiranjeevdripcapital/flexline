import { StatusBadge } from '../components/StatusBadge'

const schedule = [
  { due: 'May 15, 2026', amount: '$4,420.12', principal: '$3,980.00', interest: '$440.12', status: 'Scheduled' },
  { due: 'Jun 15, 2026', amount: '$4,420.12', principal: '$4,010.00', interest: '$410.12', status: 'Scheduled' },
  { due: 'Apr 15, 2026', amount: '$4,200.00', principal: '$3,900.00', interest: '$300.00', status: 'Paid' },
]

export function Repayments() {
  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-flexline-navy">Repayments</h1>
        <p className="mt-1 text-sm text-flexline-muted">
          Instalments aggregate draws for the month. Status reflects operations
          marking when funds are received (ACH handled manually in MVP).
        </p>
      </div>

      <section className="overflow-hidden rounded-xl border border-flexline-border bg-white shadow-card">
        <div className="border-b border-flexline-border bg-flexline-table-head px-4 py-3">
          <h2 className="text-sm font-semibold text-flexline-navy">Upcoming & recent</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead>
              <tr className="border-b border-flexline-border bg-flexline-table-head text-xs font-semibold uppercase tracking-wide text-flexline-navy">
                <th className="px-4 py-3">Due date</th>
                <th className="px-4 py-3">Amount</th>
                <th className="px-4 py-3">Principal</th>
                <th className="px-4 py-3">Interest</th>
                <th className="px-4 py-3">Status</th>
              </tr>
            </thead>
            <tbody>
              {schedule.map((row) => (
                <tr key={row.due} className="border-b border-flexline-border last:border-0">
                  <td className="px-4 py-3 font-medium text-flexline-navy">{row.due}</td>
                  <td className="px-4 py-3">{row.amount}</td>
                  <td className="px-4 py-3 text-flexline-muted">{row.principal}</td>
                  <td className="px-4 py-3 text-flexline-muted">{row.interest}</td>
                  <td className="px-4 py-3">
                    <StatusBadge variant={row.status === 'Paid' ? 'success' : 'neutral'}>
                      {row.status}
                    </StatusBadge>
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
