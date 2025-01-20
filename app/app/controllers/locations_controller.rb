class LocationsController < ApplicationController
  def index
    # loads the locations page service
    service = App::Container["models.locations_paginated_service"]

    # queries the db for the paginated locations and formats the page
    page = service.call(params)

    # returns the page as json
    render(json: page)
  end
end
