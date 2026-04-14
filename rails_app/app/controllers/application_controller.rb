# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_user, :current_organization

  private

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
