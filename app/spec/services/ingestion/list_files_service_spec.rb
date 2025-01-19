require "rails_helper"

RSpec.describe Ingestion::ListFilesService, type: :service do
  let(:logger) { instance_double("Logger") }
  let(:ingest_dir) { "/path/to/ingest_dir" }
  let(:files) { [ "file1.csv", "file2.csv" ] }

  before do
    allow(Rails.application.config).to(receive(:ingest_dir).and_return(ingest_dir))
    allow(Dir).to(receive(:glob).with("#{ingest_dir}/*.csv").and_return(files))
    allow(logger).to(receive(:info))
  end

  subject { described_class.new(logger: logger) }

  describe "#list_files" do
    context("when files are listed successfully") do
      it "logs the listing of files" do
        expect(logger).to(receive(:info).with("Listing csv files in #{ingest_dir}"))
        subject.call
      end

      it "logs each file being processed" do
        files.each do |file|
          expect(logger).to(receive(:info).with("Processing file #{file}"))
        end

        subject.call
      end

      it "returns Success with the list of files" do
        result = subject.call
        expect(result).to(be_success)
        expect(result.value!).to(eq(files))
      end
    end

    context("when an error occurs during file processing") do
      let(:error) { StandardError.new("An error occurred") }

      before do
        allow(logger).to(receive(:info).with("Processing file #{files.first}").and_raise(error))
      end

      it "returns Failure with the error" do
        result = subject.call
        expect(result).to(be_failure)
        expect(result.failure).to(eq(error))
      end
    end
  end
end
