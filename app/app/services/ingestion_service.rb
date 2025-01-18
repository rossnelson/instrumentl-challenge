class IngestionService
  include Dry::Transaction(container: Container)
  include Import[:logger]

  step :validate

  private

  # boilerplate to make sure everything is setup and ready to go
  def validate(input)
    logger.info("Validating #{input}")

    return Success(input) if input.present?

    Failure(:invalid_input)
  end
end
