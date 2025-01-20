class ProcessFileJob < ApplicationJob
  queue_as :default

  def perform(file)
    result = App::Container["ingestion.process_file_service"].call(file)
    raise result.failure if result.failure?
  end
end
