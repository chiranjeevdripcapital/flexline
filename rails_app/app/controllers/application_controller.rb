# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_portal_active!, if: :portal_guard_needed?

  helper_method :current_user, :current_organization

  private

  def portal_guard_needed?
    current_user.present? &&
      current_organization.present? &&
      !current_organization.portal_active? &&
      !skip_portal_status_check?
  end

  def skip_portal_status_check?
    controller_name.in?(%w[sessions portal_suspensions])
  end

  def ensure_portal_active!
    redirect_to portal_suspension_path
  end

  def authenticate_user!
    return if controller_name == "sessions"

    redirect_to login_path, alert: "Please sign in to continue." unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_organization
    @current_organization ||= current_user&.organization
  end
end
