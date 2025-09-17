Rails.application.routes.draw do
  get "welcome/index"

  # Reveal health status
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "authors#index"

  # Authors routes with fetch_latest
  resources :authors do
    member do
      get :fetch_latest
      get :fetch_latest_spotify
    end
  end
end
