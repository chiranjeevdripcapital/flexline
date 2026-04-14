# frozen_string_literal: true

module ApplicationHelper
  def format_money(cents)
    return "—" if cents.nil?

    number_to_currency(cents.to_d / 100, precision: 2)
  end

  def bank_account_status_pill_classes(account)
    case account.verification_status
    when "verified"
      "border-emerald-200 bg-emerald-50 text-emerald-900"
    when "failed"
      "border-rose-200 bg-rose-50 text-rose-900"
    when "micro_deposit_sent", "awaiting_plaid"
      "border-amber-200 bg-flexline-pending text-flexline-pending-text"
    else
      "border-slate-200 bg-slate-50 text-slate-800"
    end
  end

  def bank_account_status_label(account)
    case account.verification_status
    when "verified" then "Verified"
    when "failed" then "Failed"
    when "micro_deposit_sent" then "Micro-deposits sent"
    when "awaiting_plaid" then "Awaiting Plaid"
    when "incomplete" then "Incomplete"
    else account.verification_status.to_s.tr("_", " ").titleize
    end
  end

  def nav_link_to(name, path)
    active = current_page?(path)
    base = "block rounded-lg px-3 py-2.5 text-sm font-semibold transition"
    cls =
      if active
        "#{base} bg-flexline-navy text-white"
      else
        "#{base} text-flexline-muted hover:bg-white/80"
      end
    link_to name, path, class: cls
  end
end
