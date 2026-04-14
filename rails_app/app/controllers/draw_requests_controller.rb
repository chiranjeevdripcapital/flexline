# frozen_string_literal: true

class DrawRequestsController < ApplicationController
  def new; end

  def create
    redirect_to root_path, notice: "Draw request recorded (demo — no persistence yet)."
  end

  def show
    @draw_id = params[:id]
  end
end
