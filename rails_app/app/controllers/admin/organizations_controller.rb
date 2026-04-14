# frozen_string_literal: true

module Admin
  class OrganizationsController < Admin::ApplicationController
    PER_PAGE = 30

    def index
      scope = Organization.order(:name)
      if params[:q].to_s.strip.present?
        term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip.downcase)}%"
        scope = scope.where("LOWER(name) LIKE ?", term)
      end
      @page = [ params[:page].to_i, 1 ].max
      @total_count = scope.count
      @organizations = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
      @total_pages = [ (@total_count / PER_PAGE.to_f).ceil, 1 ].max
    end

    def show
      @organization = Organization.includes(:bank_accounts, draws: :bank_account).find(params[:id])
      @recent_draws = @organization.draws.includes(:bank_account).recent_first.limit(25)
      @admin_events = @organization.admin_events.recent_first.limit(50)
    end
  end
end
