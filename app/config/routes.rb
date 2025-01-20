Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Render dynamic PWA files from app/views/pwa/*
  get("/locations", to: "locations#index")
  get("/locations/:location_id/inspections", to: "locations/inspections#index")
  # Defines the root path route ("/")
  # root "posts#index"
end
