module Ingestion
  # this class will list all files in the configured ingest directory
  # and send each file to the ProcessFileJob for queued processing

  class QueueFilesService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    step :list_files

    private

    def list_files
      logger.info("Listing csv files in #{Rails.application.config.ingest_dir}")

      # list all files in the configured ingest directory
      files = Dir.glob("#{Rails.application.config.ingest_dir}/*.csv")
      logger.info("Found #{files.count} files")

      # send each file to the ProcessFileJob for queued processing
      files.each do |file|
        ProcessFileJob.perform_later(file)
      rescue => e
        # if the file cannot be processed, return the monadic error
        logger.error("Failed to queue file #{file}: #{e.message}")
        return Failure(e)
      end

      # once all files are queued, return the list of files as a monadic success
      logger.info("Finished queue files (#{files.count} files found)")
      Success(files)
    end
  end
end
