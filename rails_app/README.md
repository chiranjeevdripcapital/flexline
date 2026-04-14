# Flexline (Rails)

Borrower portal MVP scaffold using **Ruby on Rails 8**, **SQLite**, **Propshaft**, and **tailwindcss-rails**. UI tokens mirror the `Design reference/` screenshots (navy + green, Montserrat).

## Requirements

- Ruby **3.2+** (`.ruby-version` pins 3.3.6)
- Bundler

## Setup

```bash
cd rails_app
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/rails server
```

Visit `http://localhost:3000` (you’ll be redirected to sign in).

### Demo credentials (from `db/seeds.rb`)

- **Email:** `pilot@example.com`
- **Password:** `password123`

This seeds an organization (`importer_external_id: demo-importer-001`) with a credit line, a verified bank account, and a second account waiting on micro-deposits.

**Operations console:** `/admin/draws` (set `FLEXLINE_ADMIN_PASSWORD` in production; development defaults to user `admin` / password `development`).

### CSS watch (development)

```bash
bin/dev
```

Runs `rails server` and `tailwindcss:watch` via Foreman.

## Note on `web/`

The separate **Vite + React** app in [`../web/`](../web/) was an earlier UI spike. **This Rails app is the intended primary stack** for the MVP going forward.

---

## Product flows implemented in this app

- **Draws:** Borrower submits a draw → status **Processing** → operations uses **`/admin/draws`** (HTTP Basic) to **Approve & fund** (creates instalments, then sets `available_cents` to match **limit − outstanding principal**) or **Decline** (optional borrower-facing reason). Emails are queued when a draw is submitted, funded, or declined. The portal shows **available to draw** as **`credit_limit_cents − outstanding_principal_cents`** (not a separately drifting number).
- **Repayments:** **`/repayments`** groups all funded draws’ instalments by **`due_on`** and shows **one row per payment date** with **ACH debit (this pull)** = sum of line amounts that day, plus a **per-draw breakdown**. Matches the business rule: **one ACH per date** even when multiple draws have a line on that date.
- **Importer limits:** `POST /internal/admin/facilities/sync` with header **`X-Flexline-Facility-Token`** updates `credit_limit_cents`, `available_cents`, `portal_status`, and `name` for the row keyed by **`importer_external_id`**. Demo org in seeds uses `importer_external_id: demo-importer-001`.
- **Portal suspension:** If `portal_status` is **`suspended`**, signed-in users are redirected to **`/portal_suspension`** (draws and bank changes are blocked until sync sets `active` again).
- **Plaid:** With **`PLAID_CLIENT_ID`** and **`PLAID_SECRET`** set, the bank verification page shows **Open Plaid Link** (token + exchange run on the server). Set **`PLAID_ENV`** to `sandbox`, `development`, or `production`. Optional: **`PLAID_WEBHOOK_URL`** (https), **`PLAID_RETAIN_ACCESS_TOKEN=true`** if you must keep Items instead of removing them after verify (default removes the Item so access tokens are not stored long-term).

---

## Where we need your help (credentials & ops)

| Item | What to provide |
| --- | --- |
| **Email delivery (production)** | `FLEXLINE_MAILER_FROM`, `APP_HOST`, and either install SMTP ENV (`SMTP_ADDRESS`, … — see `config/initializers/smtp.rb`) or change `MAILER_DELIVERY_METHOD` / use a provider your DevOps prefers. |
| **Plaid** | Dashboard **client_id** + **secret** → `PLAID_CLIENT_ID`, `PLAID_SECRET`, `PLAID_ENV`. Without these, only micro-deposit verification is available in deployed environments. A local-only “complete verification (test)” action exists when `RAILS_ENV=development`. |
| **Admin UI** | `FLEXLINE_ADMIN_USERNAME` / **`FLEXLINE_ADMIN_PASSWORD`** for `/admin/draws` (defaults in development/test only: `admin` / `development`). |
| **Importer → portal sync** | A shared secret in **`FLEXLINE_FACILITY_SYNC_TOKEN`** and your admin job POSTing JSON to **`/internal/admin/facilities/sync`** with header **`X-Flexline-Facility-Token`**. |
| **Security hardening (next engineering pass)** | Encrypt `routing_number` / `account_number` at rest, rotate secrets, and attach real observability—**not** wired in this MVP branch. |
