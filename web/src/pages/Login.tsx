import type { FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../components/Button'

export function Login() {
  const navigate = useNavigate()

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    navigate('/')
  }

  return (
    <div className="flex min-h-screen flex-col bg-flexline-sidebar">
      <header className="border-b border-flexline-border bg-white px-6 py-4">
        <span className="text-lg font-bold text-flexline-navy">Flexline</span>
      </header>
      <div className="flex flex-1 items-center justify-center p-6">
        <div className="w-full max-w-md rounded-xl border border-flexline-border bg-white p-8 shadow-card">
          <h1 className="text-xl font-bold text-flexline-navy">Sign in</h1>
          <p className="mt-1 text-sm text-flexline-muted">
            Standalone pilot login (no US SCF portal switcher in MVP).
          </p>
          <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
            <div>
              <label
                htmlFor="email"
                className="block text-xs font-semibold uppercase tracking-wide text-flexline-muted"
              >
                Email
              </label>
              <input
                id="email"
                type="email"
                autoComplete="username"
                placeholder="you@company.com"
                className="mt-1 w-full rounded-lg border border-flexline-border px-3 py-2.5 text-sm outline-none ring-flexline-green focus:ring-2"
              />
            </div>
            <div>
              <label
                htmlFor="password"
                className="block text-xs font-semibold uppercase tracking-wide text-flexline-muted"
              >
                Password
              </label>
              <input
                id="password"
                type="password"
                autoComplete="current-password"
                placeholder="••••••••"
                className="mt-1 w-full rounded-lg border border-flexline-border px-3 py-2.5 text-sm outline-none ring-flexline-green focus:ring-2"
              />
            </div>
            <Button type="submit" className="w-full">
              Continue
            </Button>
          </form>
        </div>
      </div>
    </div>
  )
}
