# frozen_string_literal: true

module Admin
  class DrawsController < Admin::ApplicationController
    before_action :set_draw, only: %i[show update_notes approve decline]

    RENDER_LIMIT = 100
    CSV_LIMIT = 2000

    def index
      scope = filtered_draw_scope.includes(:organization, :bank_account)
      respond_to do |format|
        format.html { @draws = scope.limit(RENDER_LIMIT) }
        format.csv do
          rows = scope.limit(CSV_LIMIT).includes(:organization, :bank_account)
          send_data draws_to_csv(rows),
            filename: "flexline-draws-#{Time.zone.now.strftime('%Y%m%d-%H%M')}.csv",
            type: "text/csv; charset=utf-8"
        end
      end
    end

    def show
      @admin_events = @draw.admin_events.recent_first.limit(40)
    end

    def update_notes
      prev = @draw.operator_notes.to_s
      if @draw.update(operator_notes: draw_notes_params[:operator_notes])
        if @draw.operator_notes.to_s != prev
          AdminEvent.record!(
            action: "draw_operator_notes_updated",
            actor_identifier: admin_actor_identifier,
            draw: @draw,
            metadata: { "preview" => @draw.operator_notes.to_s.truncate(200) }
          )
        end
        redirect_to admin_draw_path(@draw), notice: "Operator notes saved."
      else
        redirect_to admin_draw_path(@draw), alert: @draw.errors.full_messages.to_sentence
      end
    end

    def approve
      if @draw.approve_and_fund!
        AdminEvent.record!(
          action: "draw_approved",
          actor_identifier: admin_actor_identifier,
          draw: @draw,
          metadata: { "amount_cents" => @draw.amount_cents, "term_months" => @draw.term_months }
        )
        FlexlineMailer.draw_funded(@draw).deliver_later
        redirect_to admin_draw_path(@draw), notice: "Draw funded and instalments created."
      else
        redirect_to admin_draw_path(@draw), alert: @draw.errors.full_messages.presence || "Could not fund draw."
      end
    end

    def decline
      internal = params[:internal_decline_code].to_s.strip
      if internal.blank?
        redirect_to admin_draw_path(@draw), alert: "Select an internal decline reason."
        return
      end

      reason = params[:decline_reason].to_s.strip
      if @draw.decline!(reason: reason.presence || "Declined by operations.", internal_decline_code: internal)
        AdminEvent.record!(
          action: "draw_declined",
          actor_identifier: admin_actor_identifier,
          draw: @draw,
          metadata: {
            "internal_decline_code" => internal,
            "decline_reason_preview" => @draw.decline_reason.to_s.truncate(200)
          }
        )
        FlexlineMailer.draw_declined(@draw).deliver_later
        redirect_to admin_draw_path(@draw), notice: "Draw marked declined."
      else
        redirect_to admin_draw_path(@draw), alert: @draw.errors.full_messages.presence || "Could not decline draw."
      end
    end

    private

    def set_draw
      @draw = Draw.includes(:organization, :bank_account, :installments).find(params[:id])
    end

    def draw_notes_params
      params.fetch(:draw, {}).permit(:operator_notes)
    end

    def filtered_draw_scope
      scope = Draw.all
      st = params[:status].to_s.strip
      scope = scope.where(status: st) if st.present? && Draw::STATUSES.include?(st)

      if (from = parse_date(params[:from]))
        scope = scope.where("draws.created_at >= ?", from.beginning_of_day)
      end
      if (to = parse_date(params[:to]))
        scope = scope.where("draws.created_at <= ?", to.end_of_day)
      end

      q = params[:q].to_s.strip
      if q.present?
        like = "%#{ActiveRecord::Base.sanitize_sql_like(q.downcase)}%"
        scope = scope.left_joins(:organization).where(
          "LOWER(organizations.name) LIKE ? OR CAST(draws.id AS TEXT) LIKE ?",
          like,
          "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
        )
      end

      case params[:sort].to_s
      when "oldest"
        scope.oldest_first
      when "amount_high"
        scope.by_amount_desc
      when "amount_low"
        scope.by_amount_asc
      else
        scope.recent_first
      end
    end

    def parse_date(raw)
      return nil if raw.blank?

      Date.parse(raw.to_s)
    rescue ArgumentError
      nil
    end

    def draws_to_csv(rows)
      header = %w[id public_code organization_name amount_cents term_months status created_at funded_at bank_mask age_in_queue_description]
      lines = [ format_csv_line(header) ]
      rows.each do |d|
        age =
          if d.status == "processing"
            "#{((Time.current - d.created_at) / 3600.0).round(1)}h since submit"
          else
            "—"
          end
        lines << format_csv_line(
          [
            d.id,
            d.public_code,
            d.organization.name,
            d.amount_cents,
            d.term_months,
            d.status,
            d.created_at.iso8601,
            d.funded_at&.iso8601,
            d.bank_account.mask_last4,
            age
          ]
        )
      end
      lines.join("\n") + "\n"
    end

    def format_csv_line(values)
      values.map { |v| escape_csv_field(v) }.join(",")
    end

    def escape_csv_field(value)
      s = value.nil? ? "" : value.to_s
      return "\"#{s.gsub('"', '""')}\"" if /[",\r\n]/.match?(s)

      s
    end
  end
end
