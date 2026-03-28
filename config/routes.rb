Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "/today", to: "challenges#today", as: :today_challenge
  get "/draw/:step", to: "drawings#show", as: :draw
  get "/done", to: "drawings#done", as: :done
  get   "/password_reset",          to: "password_resets#new",    as: :new_password_reset
  post  "/password_reset",          to: "password_resets#create"
  get   "/password_reset/edit",     to: "password_resets#edit",   as: :edit_password_reset
  patch "/password_reset",          to: "password_resets#update"

  get  "/sign_in",  to: "sessions#new",      as: :sign_in
  post "/sign_in",  to: "sessions#create"
  delete "/sign_out", to: "sessions#destroy", as: :sign_out
  get "/auth/google_oauth2/callback", to: "sessions#google"

  post "/submissions", to: "submissions#create", as: :submissions
  get  "/upload", to: "uploads#show", as: :upload
  post "/upload", to: "uploads#create"
  get  "/sign_up",  to: "registrations#new",    as: :sign_up
  post "/sign_up",  to: "registrations#create"
  get  "/username", to: "registrations#pick_username", as: :pick_username
  patch "/username", to: "registrations#set_username"

  # Defines the root path route ("/")
  # root "posts#index"
end
