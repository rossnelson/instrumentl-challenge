class LocationsController < ApplicationController
  def index
    strong_params = params.permit(:page, :per_page, :search, :postal_code)

    # loads the locations page service
    service = App::Container["models.locations_paginated_service"]

    # queries the db for the paginated locations and formats the page
    page = service.call(strong_params)

    if page.failure?
      return render(json: {error: page.failure}, status: 400)
    end

    # returns the page as json
    render(json: page.value_or(nil))
  end
end
