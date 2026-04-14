# Flexline

Pilot line-of-credit borrower portal (MVP).

## Product

See [docs/mvp-prd.md](docs/mvp-prd.md).

## Applications

### Rails (primary)

The **Ruby on Rails 8** app lives in [`rails_app/`](rails_app/). See [`rails_app/README.md`](rails_app/README.md) for setup (Ruby **3.2+**, `bundle install`, `bin/rails db:prepare`, `bin/rails tailwindcss:build`).

### Vite + React (spike)

[`web/`](web/) is an earlier **Vite + React** UI spike with the same visual language. New work should target **Rails** unless you explicitly choose a split stack.

## Design reference

Screenshots in `Design reference/` are **visual reference only** (not bundled into either app).
