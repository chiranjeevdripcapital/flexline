# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @organization = current_organization
    @draws = @organization.draws.recent_first.limit(25)
  end
end
