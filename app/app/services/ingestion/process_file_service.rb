module Ingestion
  class ProcessFileService
    include Dry::Transaction(container: Container)
    include Import[:logger]
  end
end
