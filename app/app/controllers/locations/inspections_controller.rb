class Locations::InspectionsController < LocationsController
  def index
    # loads the inspections page service
    service = App::Container["models.inspections_paginated_service"]

    # queries the db for the paginated inspections and formats the page
    page = service.call(params)

    # returns the page as json
    render(json: page)
  end
end
