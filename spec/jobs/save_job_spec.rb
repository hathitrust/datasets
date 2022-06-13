require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/save_job"
require "pathname"

module Datasets
  RSpec.describe SaveJob do
    include_context "with mocked job parameters"
    let(:params) { [volume, src_path, volume_writer] }

    it_behaves_like "a job" do
      let(:job) { described_class.new }
    end

    describe "#perform" do
      it "saves the volume" do
        serialized_params = described_class.serialize(*params)
        expect(volume_writer).to receive(:save).with(volume, src_path)
        described_class.new.perform(*serialized_params)
      end
    end
  end
end
