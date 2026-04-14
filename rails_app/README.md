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
bin/rails tailwindcss:build
bin/rails server
```

Visit `http://localhost:3000`. Sign in UI: `http://localhost:3000/login` (demo submit only sets a session flag).

### CSS watch (development)

```bash
bin/dev
```

Runs `rails server` and `tailwindcss:watch` via Foreman.

## Note on `web/`

The separate **Vite + React** app in [`../web/`](../web/) was an earlier UI spike. **This Rails app is the intended primary stack** for the MVP going forward.
