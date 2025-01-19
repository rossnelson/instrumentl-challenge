require "rails_helper"
require "csv"

RSpec.describe Ingestion::ProcessFileService, type: :service do
  let(:logger) { instance_double("Logger") }
  let(:service) { described_class.new(logger: logger) }
  let(:file_path) { "spec/fixtures/files/test.csv" }
  let(:csv_content) { "header1,header2\nvalue1,value2\nvalue3,value4" }

  before do
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:error))
    allow(CSV).to(
      receive(:foreach)
        .and_yield(0, CSV::Row.new([ "header1", "header2" ], [ "value1", "value2" ]))
        .and_yield(1, CSV::Row.new([ "header1", "header2" ], [ "value3", "value4" ]))
    )
  end

  describe "#call" do
    context("when the file is successfully read and processed") do
      it "processes each row in the CSV file" do
        service.call(file_path)
        expect(logger).to(
          have_received(:info).with(
            "Processing row(0) from #{file_path}: {\"header1\":\"value1\",\"header2\":\"value2\"}"
          )
        )
        expect(logger).to(
          have_received(:info).with(
            "Processing row(1) from #{file_path}: {\"header1\":\"value3\",\"header2\":\"value4\"}"
          )
        )
      end

      it "returns a monadic success with the file path" do
        result = service.call(file_path)
        expect(result).to(be_a(Dry::Monads::Result::Success))
        expect(result.value!).to(eq(file_path))
      end
    end

    context("when reading the file fails") do
      let(:error) { StandardError.new("some error") }

      before do
        allow(CSV).to(receive(:foreach).and_raise(error))
      end

      it "returns a monadic failure" do
        result = service.call(file_path)
        expect(result).to(be_a(Dry::Monads::Result::Failure))
        expect(result.failure).to(eq(error))
      end
    end
  end
end
