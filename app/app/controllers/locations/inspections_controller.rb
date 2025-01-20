class Locations::InspectionsController < LocationsController
  def index
    strong_params = params.permit(
      :location_id,
      :page,
      :size,
      :min_score,
      :max_score
    )

    # loads the inspections page service
    service = App::Container["models.inspections_paginated_service"]

    # queries the db for the paginated inspections and formats the page
    page = service.call(strong_params)

    if page.failure?
      return render(json: {error: page.failure}, status: 400)
    end

    # returns the page as json
    render(json: page.value_or(nil))
  end
end
