Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Locations
  get("/locations", to: "locations#index")
  get("/locations/:location_id/inspections", to: "locations/inspections#index")

  # Inspections
  get("/inspections", to: "inspections#index")

  # Metrics
  get("/metrics", to: "metrics#index")
end
