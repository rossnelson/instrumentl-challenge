module Models
  # MetricsService builds query params as a struct, builds the content based on
  # the params, and returns the aggregated result

  class MetricsService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    step :validate_parameters
    step :build_parameters
    step :get_metrics
    step :as_json

    private

    def validate_parameters(params)
      result = ParametersContract.call(params.to_h)

      return Failure(result.errors.to_h) if result.failure?

      Success(params)
    rescue => e
      logger.error("Failed to validate parameters #{params}: #{e.message}")
      Failure(e)
    end

    def build_parameters(params)
      Success(Parameters.new(params))

    rescue => e
      logger.error("Failed to build parameters #{params}: #{e.message}")
      Failure(e)
    end

    def get_metrics(params)
      metrics = Metric
        .select(
          "location_id",
          "location_name",
          "to_char(date, 'YYYY-MM') AS month",
          "CASE WHEN SUM(score_count) = 0 THEN 0 ELSE SUM(score_sum) / SUM(score_count) END AS avg_score",
          "SUM(inspection_count) AS inspection_count",
          "SUM(violation_count) AS violation_count"
        )
          .where(date: params.start..params.end)
        .group("location_id, location_name, to_char(date, 'YYYY-MM')")

        if params.min_score.present?
          metrics = metrics.where(
            "CASE WHEN SUM(score_count) = 0 THEN 0 ELSE SUM(score_sum) / SUM(score_count) END >= ?",
            params.min_score
          )
        end

        if params.max_score.present?
          metrics = metrics.where(
            "CASE WHEN SUM(score_count) = 0 THEN 0 ELSE SUM(score_sum) / SUM(score_count) END <= ?",
            params.max_score
          )
        end

        metrics = metrics.order(params.order)

        if params.top_n.present?
          metrics = metrics.limit(params.top_n)
        end

        if params.location_id.present?
          metrics = metrics.where(location_id: params.location_id)
        end

      Success(metrics)
    rescue => e
      logger.error("Failed to get metrics #{params}: #{e.message}")
      Failure(e)
    end

    def as_json(metrics)
      Success(metrics.as_json({except: :id}))
    rescue => e
      Failure(e)
    end

    class ParametersContract < Dry::Validation::Contract
      include App::Deps[:logger]

      params do
        required(:start).filled(:string)
        required(:end).filled(:string)

        optional(:top_n).filled(:integer)
        optional(:order).filled(:string)
        optional(:min_score).filled(:integer)
        optional(:max_score).filled(:integer)
        optional(:location_id).filled(:integer)
      end

      rule(:start, :end) do
        next if values[:start] < values[:end]
        key(:start).failure("start must be before end")
      end

      rule(:top_n) do
        next if !values[:top_n].present? || values[:top_n] > 0
        key(:top_n).failure("top_n must be greater than 0")
      end

      def self.call(params)
        new.call(params)
      end
    end

    class Parameters < Dry::Struct
      transform_keys(&:to_sym)

      attribute :start, Types::String.constrained(format: /\d{4}-\d{2}-\d{2}/)
      attribute :end, Types::String.constrained(format: /\d{4}-\d{2}-\d{2}/)
      attribute? :top_n, Types::Coercible::Integer.optional
      attribute? :order, Types::String.optional.default("location_name, month, avg_score".freeze)
      attribute? :min_score, Types::Coercible::Integer.optional
      attribute? :max_score, Types::Coercible::Integer.optional
      attribute? :location_id, Types::Coercible::Integer.optional
    end
  end
end
