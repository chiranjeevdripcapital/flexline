import { Link, NavLink, Outlet } from 'react-router-dom'

const nav = [
  { to: '/', label: 'Dashboard', end: true },
  { to: '/bank-accounts', label: 'Bank accounts' },
  { to: '/request-draw', label: 'Request draw' },
  { to: '/repayments', label: 'Repayments' },
]

export function AppShell() {
  return (
    <div className="flex min-h-screen bg-white">
      <aside className="flex w-64 shrink-0 flex-col border-r border-flexline-border bg-flexline-sidebar">
        <div className="border-b border-flexline-border px-4 py-4">
          <div className="text-lg font-bold tracking-tight text-flexline-navy">
            Flexline
          </div>
          <button
            type="button"
            className="mt-3 flex w-full items-center justify-between rounded-lg border border-flexline-border bg-white px-3 py-2 text-left text-xs font-medium text-flexline-navy"
          >
            <span className="truncate">Demo Company Ltd.</span>
            <span aria-hidden>▾</span>
          </button>
        </div>
        <nav className="flex flex-1 flex-col gap-0.5 p-2">
          {nav.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `rounded-lg px-3 py-2.5 text-sm font-semibold transition ${
                  isActive
                    ? 'bg-flexline-navy text-white'
                    : 'text-flexline-muted hover:bg-white/80'
                }`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="border-t border-flexline-border p-4 text-xs text-flexline-muted">
          <div className="font-semibold text-flexline-navy">Account manager</div>
          <div className="mt-1">Ops support (placeholder)</div>
        </div>
      </aside>
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-14 items-center justify-end gap-4 border-b border-flexline-border px-6">
          <Link
            to="/login"
            className="mr-auto text-xs font-semibold text-flexline-muted hover:text-flexline-navy"
          >
            Sign out
          </Link>
          <button
            type="button"
            className="rounded-full p-2 text-flexline-muted hover:bg-flexline-sidebar"
            aria-label="Notifications"
          >
            <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" aria-hidden>
              <path
                d="M12 22a2 2 0 002-2H10a2 2 0 002 2zm6-6V11a6 6 0 10-12 0v5l-2 2v1h16v-1l-2-2z"
                fill="currentColor"
              />
            </svg>
          </button>
          <div className="flex items-center gap-2">
            <div className="text-right text-sm leading-tight">
              <div className="font-semibold text-flexline-navy">Alex Pilot</div>
              <div className="text-xs text-flexline-muted">Borrower</div>
            </div>
            <div className="flex h-9 w-9 items-center justify-center rounded-md bg-flexline-navy text-xs font-bold text-white">
              AP
            </div>
          </div>
        </header>
        <main className="flex-1 bg-[#f8fafc] p-6 lg:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
