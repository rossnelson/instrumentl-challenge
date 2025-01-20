module Models
  # InspectionsPaginatedService will build query params as a struct, build the
  # content based on the params, and format the page using the page service

  class InspectionsPaginatedService
    include Dry::Transaction(container: App::Container)
    include App::Deps["resources.page_service"]

    step :build_params
    step :build_content
    step :format_page

    private

    def build_params(params)
      params = Parameters.new(params)

      Success(params)
    rescue => e
      Failure(e)
    end

    def build_content(parameters)
      # uses kaminari to paginate the locations
      inspections = Inspection
        .includes(:inspection_kind, violations: [:risk_category, :violation_kind])
        .page(parameters.page)
        .per(parameters.size)

      if parameters.location_id.present?
        inspections = inspections.where(location_id: parameters.location_id)
      end

      if parameters.min_score.present?
        inspections = inspections.where("score >= ?", parameters.min_score)
      end

      if parameters.max_score.present?
        inspections = inspections.where("score <= ?", parameters.max_score)
      end

      Success(inspections)
    rescue => e
      Failure(e)
    end

    def format_page(inspections)
      # uses the page service to format the page
      Success(
        page_service.call(
          content: inspections,
          json_options: json_options
        )
      )

    rescue => e
      Failure(e)
    end

    def json_options
      {
        only: [:id, :score, :occurred_at, :location_id],
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
    end

    class Parameters < Dry::Struct
      transform_keys(&:to_sym)

      attribute? :location_id, Types::Coercible::Integer.optional
      attribute? :page, Types::Coercible::Integer.default(1)
      attribute? :size, Types::Coercible::Integer.default(25)
      attribute? :min_score, Types::Coercible::Integer.optional
      attribute? :max_score, Types::Coercible::Integer.optional
    end
  end
end
