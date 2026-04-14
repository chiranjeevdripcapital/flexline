# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  layout "auth"

  def new; end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out."
  end
end
