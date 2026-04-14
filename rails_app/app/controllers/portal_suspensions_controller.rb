# frozen_string_literal: true

class PortalSuspensionsController < ApplicationController
  def show
    @organization = current_organization
  end
end
