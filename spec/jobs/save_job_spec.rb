require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/save_job"
require "pathname"

module Datasets

  RSpec.describe SaveJob do
    include_context "with mocked job parameters"

    it_behaves_like "a job" do
      let(:job) { described_class.new(volume, src_path, volume_writer) }
    end

    describe "#perform" do
      it "saves the volume" do
        expect(volume_writer).to receive(:save).with(volume, src_path)
        described_class.new(volume, src_path, volume_writer).perform
      end
    end
  end

end

