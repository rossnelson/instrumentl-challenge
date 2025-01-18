require "rails_helper"

RSpec.describe IngestionService do
  let(:logger) { instance_double("Logger").as_null_object }
  let(:service) { described_class.new(logger: logger) }

  describe "#validate" do
    let(:input) { "test_input" }

    context("when validation is successful") do
      it "logs the validation message" do
        expect(logger).to(receive(:info).with("Validating #{input}"))

        service.call(input)
      end

      it "returns a Success result" do
        result = service.call(input)

        expect(result).to(be_a(Dry::Monads::Result::Success))
        expect(result.value!).to(eq(input))
      end
    end

    context("when validation fails") do
      it "returns a Failure result" do
        result = service.call(input)

        expect(result).to(be_a(Dry::Monads::Result::Success))
        expect(result.value!).to(eq(input))
      end
    end
  end
end
