# frozen_string_literal: true

class SessionsController < ApplicationController
  layout "auth"

  def new; end

  def create
    session[:signed_in] = true
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
