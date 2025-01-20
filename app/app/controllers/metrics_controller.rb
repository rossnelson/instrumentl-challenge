class MetricsController < ApplicationController
  def index
    strong_params = params.permit(
      :start, :end, :top_n, :order, :min_score, :max_score, :location_id
    )

    # loads the locations page service
    service = App::Container["models.metrics_service"]

    # queries the db for the paginated locations and formats the page
    result = service.call(strong_params)

    if result.failure?
      return render(json: {error: result.failure}, status: 400)
    end

    # returns the page as json
    render(json: result.value_or(nil))
  end
end
