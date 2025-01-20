require "csv"

module Ingestion
  # ProcessFileService will read each line of a csv file and send each row to the
  # process inspection queue

  class ProcessFileService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    step :read_file

    private

    def read_file(input)
      logger.info("Reading file #{input}")

      # stream each csv row to the process inspection queue
      CSV.foreach(input, headers: true) do |row|
        # converting row to hash
        message = row.to_h
        logger.info("Queueing row from #{input}: #{message}")

        # queue the message to the process inspection job
        ProcessInspectionJob.perform_later(message)
      end

      logger.info("Finished reading file: #{input}")
      Success(input)
    rescue => e
      logger.error("Failed to read file #{input}: #{e.message}")
      Failure(e)
    end
  end
end
