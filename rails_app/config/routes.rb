# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get "login", to: "sessions#new"
  post "session", to: "sessions#create", as: :session
  delete "session", to: "sessions#destroy"

  resources :bank_accounts, only: %i[index new create]
  resources :draw_requests, only: %i[new create show]
  resources :repayments, only: %i[index]
end
