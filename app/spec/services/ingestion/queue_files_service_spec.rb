require "rails_helper"

RSpec.describe Ingestion::QueueFilesService, type: :service do
  let(:logger) { instance_double("Logger") }
  let(:service) { described_class.new(logger: logger) }
  let(:ingest_dir) { Rails.application.config.ingest_dir }
  let(:files) { [ "#{ingest_dir}/file1.csv", "#{ingest_dir}/file2.csv" ] }

  before do
    allow(logger).to(receive(:info))
    allow(logger).to(receive(:error))
    allow(Dir).to(receive(:glob).and_return(files))
  end

  describe "#call" do
    context("when files are successfully listed and queued") do
      before do
        allow(ProcessFileJob).to(receive(:perform_later))
      end

      it "queues each file for processing" do
        service.call
        files.each do |file|
          expect(ProcessFileJob).to(have_received(:perform_later).with(file))
        end
      end

      it "returns a monadic success with the list of files" do
        result = service.call
        expect(result).to(be_a(Dry::Monads::Result::Success))
        expect(result.value!).to(eq(files))
      end
    end

    context("when a file cannot be processed") do
      let(:error) { StandardError.new("some error") }

      before do
        allow(ProcessFileJob).to(receive(:perform_later).and_raise(error))
      end

      it "logs the error" do
        service.call
        expect(logger).to(have_received(:error).with("Failed to queue file #{files.first}: #{error.message}"))
      end

      it "returns a monadic failure" do
        result = service.call
        expect(result).to(be_a(Dry::Monads::Result::Failure))
        expect(result.failure).to(eq(error))
      end
    end
  end
end
