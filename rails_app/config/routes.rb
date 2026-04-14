# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get "login", to: "sessions#new"
  post "session", to: "sessions#create", as: :session
  delete "session", to: "sessions#destroy"

  resources :bank_accounts, only: %i[index new create show] do
    member do
      post :plaid_complete
      post :micro_confirm
      post :restart_verification
      post :use_micro_deposits_instead
    end
  end
  resources :draw_requests, only: %i[new create show]
  resources :repayments, only: %i[index]
end
