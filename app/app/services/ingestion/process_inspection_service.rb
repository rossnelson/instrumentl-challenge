module Ingestion
  # this class will process each message in the process inspection queue
  # it will validate the message and upsert the data into the database
  # the order of upserts is important to maintain foreign key relationships

  class ProcessInspectionService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    # validate the event
    step :validate_message

    # upsert the contextual data
    step :upsert_risk_category
    step :upsert_violation_kind
    step :upsert_inspection_kind

    # upsert the inspection and violation data
    step :upsert_owner
    step :upsert_location
    step :upsert_inspection
    step :upsert_violation

    private

    def validate_message(message)
      logger.info("Validating message #{message}")

      result = InspectionMessageContract.call(message)

      return Success(message.transform_keys(&:to_sym)) if result.success?

      logger.error("Failed to validate message #{input}: #{result.errors.to_h}")
      Failure(result.errors.to_h)
    end

    def upsert_risk_category(input)
      logger.info("Upserting risk category #{input}")

      risk_category = RiskCategory.find_or_create_by(name: input[:risk_category])
      logger.info("Upserted risk category #{risk_category.id}")
      input[:risk_category_id] = risk_category.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert risk category #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_violation_kind(input)
      logger.info("Upserting violation kind #{input}")

      violation_kind = ViolationKind.find_or_create_by(code: input[:violation_type])
      logger.info("Upserted violation kind #{violation_kind.id}")
      input[:violation_kind_id] = violation_kind.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert violation kind #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_inspection_kind(input)
      logger.info("Upserting inspection kind #{input}")

      inspection_kind = InspectionKind.find_or_create_by(description: input[:inspection_type])
      input[:inspection_kind_id] = inspection_kind.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert inspection kind #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_owner(input)
      logger.info("Upserting owner #{input}")

      owner = Owner.find_or_create_by(
        name: input[:owner_name],
        street: input[:owner_address],
        city: input[:owner_city],
        state: input[:owner_state],
        postal_code: input[:owner_zip]
      )

      input[:owner_id] = owner.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert owner #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_location(input)
      logger.info("Upserting location #{input}")

      location = Location.find_or_create_by(
        name: input[:name],
        street: input[:address],
        city: input[:city],
        postal_code: input[:postal_code],
        owner_id: input[:owner_id]
      )

      input[:location_id] = location.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert location #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_inspection(input)
      logger.info("Upserting inspection #{input}")

      inspection = Inspection.find_or_create_by(
        score: input[:inspection_score],
        occurred_at: input[:inspection_date],
        location_id: input[:location_id],
        inspection_kind_id: input[:inspection_kind_id]
      )

      input[:inspection_id] = inspection.id

      Success(input)
    rescue => e
      logger.error("Failed to upsert inspection #{input}: #{e.message}")
      Failure(e)
    end

    def upsert_violation(input)
      logger.info("Upserting violation #{input}")

      violation = Violation.find_or_create_by(
        occurred_at: input[:violation_date],
        description: input[:description],
        violation_kind_id: input[:violation_kind_id],
        risk_category_id: input[:risk_category_id],
        location_id: input[:location_id],
        inspection_id: input[:inspection_id]
      )

      Success(input)
    rescue => e
      logger.error("Failed to upsert violation #{input}: #{e.message}")
      Failure(e)
    end
  end

  class InspectionMessageContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
      required(:address).filled(:string)
      required(:city).filled(:string)
      required(:postal_code).filled(:string)

      required(:inspection_score).maybe(:string)
      required(:inspection_date).filled(:string)
      required(:inspection_type).filled(:string)

      optional(:violation_date).maybe(:string)
      optional(:violation_type).maybe(:string)

      optional(:risk_category).maybe(:string)
      optional(:description).maybe(:string)
    end

    def self.call(message)
      new.call(message)
    end
  end
end
