namespace(:ingest) do
  task(files: :environment) do |t, args|
    # execute the list files service
    result = App::Container["ingestion.list_files_service"].call

    # exit with error if ingestion fails
    exit(1) unless result.success?

    # print success message
    puts("Successfully ingested #{result.value!.count} files")
  end
end
