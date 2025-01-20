module Models
  class MetricsService
    include Dry::Transaction(container: Container)

    step :build_parameters
    step :get_metrics
    step :as_json

    private

    def build_parameters(params)
      Success(Parameters.new(params))

    rescue => e
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
      Failure(e)
    end

    def as_json(metrics)
      Success(metrics.as_json({except: :id}))
    rescue => e
      Failure(e)
    end

    class Parameters < Dry::Struct
      transform_keys(&:to_sym)

      attribute :start, Types::String
      attribute :end, Types::String
      attribute? :top_n, Types::Coercible::Integer.optional
      attribute? :order, Types::String.optional.default("location_name, month, avg_score")
      attribute? :min_score, Types::Coercible::Integer.optional
      attribute? :max_score, Types::Coercible::Integer.optional
      attribute? :location_id, Types::Coercible::Integer.optional
    end
  end
end
