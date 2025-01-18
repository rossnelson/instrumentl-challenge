namespace(:ingest) do
  desc("Ingest data from file path")
  task(files: :environment) do |t, args|
    # move this to a Ingestion::ListFilesService service

    # list files in configured directory
    files = Dir.glob("#{Rails.application.config.ingest_dir}/*.csv")

    files.each do |file|
      # call the ingestion service
      result = App::Container[:ingestion_service].call(file)

      # exit with error if ingestion fails
      exit(1) unless result.success?

      # print success message
      puts("Successfully ingested #{file}")
    end
  end
end
