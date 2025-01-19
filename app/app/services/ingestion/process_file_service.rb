require "csv"

module Ingestion
  class ProcessFileService
    include Dry::Transaction(container: Container)
    include Import[:logger]

    step :read_file

    private

    def read_file(input)
      logger.info("Reading file #{input}")

      # stream each csv row to the process inspection queue
      CSV.foreach(input, headers: true) do |i, row|
        message = row.to_h.to_json
        logger.info("Processing row(#{i}) from #{input}: #{message}")
        # send the message to the process inspection queue
      end

      logger.info("Finished reading file: #{input}")
      Success(input)
    rescue => e
      logger.error("Failed to read file #{input}: #{e.message}")
      Failure(e)
    end
  end
end
