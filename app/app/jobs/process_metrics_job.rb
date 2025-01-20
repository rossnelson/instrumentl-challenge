class ProcessMetricsJob < ApplicationJob
  queue_as :default

  def perform(message)
    result = App::Container["ingestion.process_metrics_service"].call(message)
    raise result.failure if result.failure?
  end
end
