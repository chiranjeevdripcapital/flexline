# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get "login", to: "sessions#new"
  post "session", to: "sessions#create", as: :session
  delete "session", to: "sessions#destroy"

  resource :portal_suspension, only: %i[show]

  resources :bank_removal_requests, only: %i[index]

  resources :bank_accounts, only: %i[index new create show] do
    resource :removal_request, only: %i[new create], controller: "bank_removal_requests"
    member do
      post :plaid_complete
      post :plaid_link_token
      post :plaid_exchange
      post :micro_confirm
      post :restart_verification
      post :use_micro_deposits_instead
    end
  end
  resources :draw_requests, only: %i[new create show]
  resources :repayments, only: %i[index]

  namespace :admin do
    root "dashboard#index"
    resources :organizations, only: %i[index show]
    resources :bank_accounts, only: %i[index]
    resources :bank_removal_requests, only: %i[index show] do
      member do
        post :approve
        post :reject
      end
    end
    resources :draws, only: %i[index show] do
      member do
        post :approve
        post :decline
        patch :update_notes
      end
    end
  end

  post "/internal/admin/facilities/sync", to: "internal/admin/facilities#sync", as: :internal_admin_facilities_sync
end
