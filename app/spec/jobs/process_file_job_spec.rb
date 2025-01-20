require "rails_helper"

RSpec.describe ProcessFileJob, type: :job do
  let(:service) { instance_double("Ingestion::ProcessFileService") }
  let(:args) { "path/to/file.csv" }

  before do
    allow(App::Container).to(receive(:[]).with("ingestion.process_file_service").and_return(service))
  end

  describe "#perform" do
    context("when the service is called successfully") do
      before do
        allow(service).to(receive(:call).with(args).and_return(Dry::Monads::Result::Success.new("Success")))
      end

      it "calls the process file service with the correct arguments" do
        expect(service).to(receive(:call).with(args))
        described_class.perform_now(*[args])
      end
    end

    context("when an error occurs during the service call") do
      let(:error_message) { "some error" }

      before do
        allow(service).to(receive(:call).with(args).and_return(Dry::Monads::Result::Failure.new(error_message)))
      end

      it "raises an error" do
        expect { described_class.perform_now(*[args]) }.to(raise_error(StandardError, error_message))
      end
    end
  end
end
