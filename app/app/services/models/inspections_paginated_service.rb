module Models
  class InspectionsPaginatedService
    include App::Deps["resources.page_service"]

    def call(params)
      # uses kaminari to paginate the locations
      inspections = Inspection
        .where(location_id: params[:location_id])
        .includes(:inspection_kind, violations: [:risk_category, :violation_kind])
        .page(params[:page] || 1)
        .per(params[:per_page] || 25)

      # uses the page service to format the page
      page_service.call(
        content: inspections,
        json_options: {
          include: {
            inspection_kind: {only: [:description]},
            violations: {
              only: [:occurred_at, :description],
              include: [
                risk_category: {only: :name},
                violation_kind: {only: :code}
              ]
            }
          }
        }
      )
    end
  end
end
