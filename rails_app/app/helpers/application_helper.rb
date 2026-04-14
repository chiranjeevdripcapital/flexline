# frozen_string_literal: true

module ApplicationHelper
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
