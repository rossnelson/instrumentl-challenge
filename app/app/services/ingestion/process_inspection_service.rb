module Ingestion
  # ProcessInspectionService will process each message in the process inspection queue
  # it will validate the message and insert the data into the database
  # the order of inserts is important to maintain foreign key relationships

  class ProcessInspectionService
    include Dry::Transaction(container: Container)
    include App::Deps[:logger]

    # validate the event
    step :validate_message

    # insert the contextual data
    step :insert_risk_category
    step :insert_violation_kind
    step :insert_inspection_kind

    # insert the inspection and violation data
    step :insert_owner
    step :insert_location
    step :insert_inspection
    step :insert_violation

    # queue the metrics
    step :queue_metrics

    private

    def validate_message(message)
      logger.info("Validating message #{message}")

      result = InspectionMessageContract.call(message)

      return Success(message.transform_keys(&:to_sym)) if result.success?

      logger.error("Failed to validate message #{input}: #{result.errors.to_h}")
      Failure(result.errors.to_h)
    end

    def insert_risk_category(input)
      logger.info("inserting risk category #{input}")

      risk_category = RiskCategory.find_or_create_by(name: input[:risk_category])
      logger.info("inserted risk category #{risk_category.id}")
      input[:risk_category_id] = risk_category.id

      Success(input)
    rescue => e
      logger.error("Failed to insert risk category #{input}: #{e.message}")
      Failure(e)
    end

    def insert_violation_kind(input)
      logger.info("inserting violation kind #{input}")

      violation_kind = ViolationKind.find_or_create_by(code: input[:violation_type])
      logger.info("inserted violation kind #{violation_kind.id}")
      input[:violation_kind_id] = violation_kind.id

      Success(input)
    rescue => e
      logger.error("Failed to insert violation kind #{input}: #{e.message}")
      Failure(e)
    end

    def insert_inspection_kind(input)
      logger.info("inserting inspection kind #{input}")

      inspection_kind = InspectionKind.find_or_create_by(description: input[:inspection_type])
      input[:inspection_kind_id] = inspection_kind.id

      Success(input)
    rescue => e
      logger.error("Failed to insert inspection kind #{input}: #{e.message}")
      Failure(e)
    end

    def insert_owner(input)
      logger.info("inserting owner #{input}")

      owner = Owner.find_or_create_by(
        name: input[:owner_name],
        street: input[:owner_address],
        city: input[:owner_city],
        state: input[:owner_state],
        postal_code: input[:owner_zip]
      )

      if owner.errors.any?
        logger.error("Failed to insert owner #{input}: #{owner.errors.full_messages}")
      end

      input[:owner_id] = owner.id

      Success(input)
    rescue => e
      logger.error("Failed to insert owner #{input}: #{e.message}")
      Failure(e)
    end

    def insert_location(input)
      logger.info("inserting location #{input}")

      location = Location.find_or_create_by!(
        name: input[:name],
        street: input[:address],
        city: input[:city],
        postal_code: input[:postal_code],
        phone_number: input[:phone_number],
        owner_id: input[:owner_id]
      )

      if location.errors.any?
        logger.error("Failed to insert location #{input}: #{location.errors.full_messages}")
      end

      input[:location_id] = location.id

      Success(input)
    rescue => e
      logger.error("Failed to insert location #{input}: #{e.message}")
      Failure(e)
    end

    def insert_inspection(input)
      logger.info("inserting inspection #{input}")

      inspection = Inspection.find_or_create_by!(
        score: input[:inspection_score],
        occurred_at: input[:inspection_date],
        location_id: input[:location_id],
        inspection_kind_id: input[:inspection_kind_id]
      )

      if inspection.errors.any?
        logger.error("Failed to insert inspection #{input}: #{inspection.errors.full_messages}")
      end

      input[:inspection_id] = inspection.id

      Success(input)
    rescue => e
      logger.error("Failed to insert inspection #{input}: #{e.message}")
      Failure(e)
    end

    def insert_violation(input)
      logger.info("inserting violation #{input}")

      violation = Violation.find_or_create_by!(
        occurred_at: input[:violation_date],
        description: input[:description],
        violation_kind_id: input[:violation_kind_id],
        risk_category_id: input[:risk_category_id],
        location_id: input[:location_id],
        inspection_id: input[:inspection_id]
      )

      if violation.errors.any?
        logger.error("Failed to insert violation #{input}: #{violation.errors.full_messages}")
      end

      input[:violation_id] = violation.id

      Success(input)
    rescue => e
      logger.error("Failed to insert violation #{input}: #{e.message}")
      Failure(e)
    end

    def queue_metrics(input)
      logger.info("Queueing metrics for #{input}")

      ProcessMetricsJob.perform_later(input)

      Success(input)
    rescue => e
      logger.error("Failed to queue metrics for #{input}: #{e.message}")
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
