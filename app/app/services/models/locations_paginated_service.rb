module Models
  class LocationsPaginatedService
    include App::Deps["resources.page_service"]

    def call(params)
      # uses kaminari to paginate the locations
      locations = Location
        .includes(:inspections, :owner)
        .page(params[:page] || 1)
        .per(params[:per_page] || 25)

      # search for locations if search param is present
      if params[:search].present?
        locations = locations.search(params[:search])
      end

      # uses the page service to format the page
      page_service.call(
        content: locations,
        json_options: {
          only: [:id, :name, :street, :city, :state, :postal_code, :phone_number],
          include: {
            owner: {only: [:id, :name]},
            inspections: {only: [:id, :occurred_at]}
          }
        }
      )
    end
  end
end
