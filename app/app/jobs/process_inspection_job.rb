class ProcessInspectionJob < ApplicationJob
  queue_as :default

  def perform(message)
    result = App::Container["ingestion.process_inspection_service"].call(message)
    raise result.failure if result.failure?
  end
end
