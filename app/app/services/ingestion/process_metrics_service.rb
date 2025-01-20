module Ingestion
  # ProcessMetricsService will process each message in the process metrics queue
  # it will increment counters on the metrics table.

  class ProcessMetricsService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    step :get_scores
    step :get_violations
    step :init_metric
    step :increment_counters
    step :save_metric

    private

    def get_scores(message)
      logger.info("Getting scores for metric #{message}")

      scores = Inspection
        .where(location_id: message[:location_id], occurred_at: message[:inspection_date])
        .pluck(:score)

      scores = scores.map(&:to_i).reject(&:zero?).push(message[:inspection_score].to_i)

      logger.info("Got scores for metric #{message}: #{scores}")
      Success({ message: message }.merge(scores: scores))
    rescue => e
      logger.error("Failed to get scores for metric #{message}: #{e.message}")
      Failure(e)
    end

    def get_violations(payload)
      message = payload[:message]

      violations = Violation.where(
        location_id: message[:location_id], occurred_at: message[:inspection_date]
      ).count

      logger.info("Got violations for metric #{message}: #{violations}")
      Success(payload.merge(violations: violations))
    rescue => e
      logger.error("Failed to get violations for metric #{message}: #{e.message}")
      Failure(e)
    end

    def init_metric(payload)
      message = payload[:message]

      logger.info("Initializing metric #{message}")

      # increment the counters for the message
      metric = Metric.find_or_initialize_by(
        date: message[:inspection_date], location_id: message[:location_id]
      ) do |m|
        m.date = message[:inspection_date]
        m.location_id = message[:location_id]
        m.location_name = message[:name]
        m.street = message[:address]
        m.city = message[:city]
        m.state = message[:state]
        m.postal_code = message[:postal_code]
      end

      Success(payload.merge(metric: metric))
    rescue => e
      logger.error("Failed to initialize metric #{message}: #{e.message}")
      Failure(e)
    end

    def increment_counters(payload)
      metric = payload[:metric]
      scores = payload[:scores]
      violations = payload[:violations]

      metric.inspection_count = scores.size
      metric.violation_count = violations
      metric.score_sum = scores.sum
      metric.score_count = scores.size

      Success(payload)
    rescue => e
      message = payload[:message]
      logger.error("Failed to increment counters for metric #{message}: #{e.message}")
      Failure(e)
    end

    def save_metric(payload)
      metric = payload[:metric]
      metric.save!

      logger.info("Saved metric #{metric}")
      Success(metric)
    rescue => e
      message = payload[:message]
      logger.error("Failed to initialize metric #{message}: #{e.message}")
      Failure(e)
    end
  end
end
