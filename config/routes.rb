Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Define routes for each function in the application
  root "fantasy#index"
  get "market" => "fantasy#market"
  get "standings" => "fantasy#standings"
  get "team" => "fantasy#team"
  get "events" => "fantasy#events"

  # Community management
  get "change_community/:id" => "fantasy#change_community", as: :change_community
  post "api/set_xauth/:id" => "fantasy#set_xauth", as: :set_xauth
end
