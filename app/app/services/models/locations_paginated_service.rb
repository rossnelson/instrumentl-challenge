module Models
  # LocationsPaginatedService will build query params as a struct, build the
  # content based on the params, and format the page using the page service

  class LocationsPaginatedService
    include Dry::Transaction(container: App::Container)
    include App::Deps["resources.page_service"]

    step :build_params
    step :build_content
    step :format_page

    def build_params(params)
      parameters = Parameters.new(params)
      Success(parameters)
    rescue => e
      Failure(e)
    end

    def build_content(parameters)
      # uses kaminari to paginate the locations
      locations = Location
        .includes(:inspections, :owner)
        .page(parameters.page)
        .per(parameters.size)

      # filter locations by postal code if postal_code param is present
      if parameters.postal_code.present?
        locations = locations.where(postal_code: parameters.postal_code)
      end

      # search for locations if search param is present
      if parameters.search.present?
        locations = locations.search(parameters.search)
      end

      Success(locations)
    rescue => e
      Failure(e)
    end

    def format_page(locations)
      # uses the page service to format the page
      page = page_service.call(
        content: locations,
        json_options: {
          only: [:id, :name, :street, :city, :state, :postal_code, :phone_number],
          include: {
            owner: {only: [:id, :name]},
            inspections: {only: [:id, :score, :occurred_at]}
          }
        }
      )

      Success(page)
    rescue => e
      Failure(e)
    end

    class Parameters < Dry::Struct
      transform_keys(&:to_sym)

      attribute? :page, Types::Coercible::Integer.default(1)
      attribute? :size, Types::Coercible::Integer.default(25)
      attribute? :search, Types::String.optional
      attribute? :postal_code, Types::String.optional
    end
  end
end
