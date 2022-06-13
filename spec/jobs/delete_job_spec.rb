require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/delete_job"
require "pathname"

module Datasets
  RSpec.describe DeleteJob do
    include_context "with mocked job parameters"
    let(:params) { [volume, volume_writer] }

    it_behaves_like "a job" do
      let(:job) { described_class.new }
    end

    describe "#perform" do
      it "deletes the volume" do
        serialized_params = described_class.serialize(*params)
        expect(volume_writer).to receive(:delete).with(volume)
        described_class.new.perform(*serialized_params)
      end
    end
  end
end
