require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/delete_job"
require "pathname"

module Datasets

  RSpec.describe DeleteJob do
    include_context "with mocked job parameters"

    it_behaves_like "a job" do
      let(:job) { described_class.new(volume, volume_writer) }
    end

    describe "#perform" do
      it "saves the volume" do
        expect(volume_writer).to receive(:delete).with(volume)
        described_class.new(volume, volume_writer).perform
      end
    end
  end

end

