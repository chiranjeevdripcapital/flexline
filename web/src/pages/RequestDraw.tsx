import { useState } from 'react'
import { Button } from '../components/Button'

export function RequestDraw() {
  const [amount, setAmount] = useState('25000')
  const [term, setTerm] = useState<'3' | '6'>('6')

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-flexline-navy">Request draw</h1>
        <p className="mt-1 text-sm text-flexline-muted">
          Enter an amount within your available limit, pick a term, and review
          the illustrative schedule before confirming.
        </p>
      </div>

      <form
        className="space-y-5 rounded-xl border border-flexline-border bg-white p-6 shadow-card"
        onSubmit={(e) => e.preventDefault()}
      >
        <div>
          <label
            htmlFor="amount"
            className="block text-xs font-semibold uppercase tracking-wide text-flexline-muted"
          >
            Draw amount (USD)
          </label>
          <input
            id="amount"
            type="text"
            inputMode="decimal"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="mt-1 w-full rounded-lg border border-flexline-border px-3 py-2.5 text-sm font-medium text-flexline-navy outline-none ring-flexline-green focus:ring-2"
          />
          <p className="mt-1 text-xs text-flexline-muted">
            Available for draw: <span className="font-semibold">$87,500</span>{' '}
            (demo)
          </p>
        </div>

        <fieldset>
          <legend className="text-xs font-semibold uppercase tracking-wide text-flexline-muted">
            Term
          </legend>
          <div className="mt-2 flex gap-3">
            {(['3', '6'] as const).map((t) => (
              <label
                key={t}
                className={`flex cursor-pointer items-center gap-2 rounded-lg border px-4 py-2 text-sm font-semibold ${
                  term === t
                    ? 'border-flexline-navy bg-flexline-navy text-white'
                    : 'border-flexline-border text-flexline-navy hover:bg-flexline-sidebar'
                }`}
              >
                <input
                  type="radio"
                  name="term"
                  value={t}
                  checked={term === t}
                  onChange={() => setTerm(t)}
                  className="sr-only"
                />
                {t} months
              </label>
            ))}
          </div>
        </fieldset>

        <div>
          <label
            htmlFor="bank"
            className="block text-xs font-semibold uppercase tracking-wide text-flexline-muted"
          >
            Disbursement account
          </label>
          <select
            id="bank"
            defaultValue="1"
            className="mt-1 w-full rounded-lg border border-flexline-border px-3 py-2.5 text-sm text-flexline-navy outline-none ring-flexline-green focus:ring-2"
          >
            <option value="1">Operating · JPM · ···4421 (verified)</option>
          </select>
        </div>

        <section className="rounded-lg border border-flexline-border bg-flexline-table-head/50 p-4 text-sm">
          <h2 className="font-semibold text-flexline-navy">Illustrative preview</h2>
          <p className="mt-2 text-xs text-flexline-muted">
            Fees and instalment breakdown will mirror finance configuration. First
            instalment interest may use a short stub period vs full month thereafter
            (per PRD open items).
          </p>
          <dl className="mt-3 grid grid-cols-2 gap-2 text-xs">
            <dt className="text-flexline-muted">Est. fee (demo)</dt>
            <dd className="text-right font-semibold text-flexline-navy">$312.50</dd>
            <dt className="text-flexline-muted">First due</dt>
            <dd className="text-right font-semibold text-flexline-navy">May 15, 2026</dd>
          </dl>
        </section>

        <div className="flex flex-wrap gap-3">
          <Button type="submit">Submit draw request</Button>
          <Button type="button" variant="ghost">
            Cancel
          </Button>
        </div>
      </form>
    </div>
  )
}
