module Ingestion
  class ListFilesService
    include Dry::Transaction(container: Container)
    include Import[:logger]

    step :list_files

    private

    def list_files
      logger.info("Listing csv files in #{Rails.application.config.ingest_dir}")
      files = Dir.glob("#{Rails.application.config.ingest_dir}/*.csv")

      files.each do |file|
        logger.info("Processing file #{file}")
      rescue => e
        return Failure(e)
      end

      Success(files)
    end
  end
end
