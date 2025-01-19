class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(*args)
    result = App::Container["ingestion.process_file_service"].call(args)
    raise result.failure if result.failure?
  end
end
