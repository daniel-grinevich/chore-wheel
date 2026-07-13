Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "weeks#show"
  get "week/:week_start", to: "weeks#show", as: :week
  post "week/:week_start/generate", to: "weeks#generate", as: :generate_week

  resources :chores
  resources :people, only: [ :index, :edit, :update ]

  post "identify/:person_id", to: "sessions#identify", as: :identify

  resources :assignments, only: [] do
    member do
      post :start_timer
      post :stop_timer
      post :reassign
    end
  end
end
