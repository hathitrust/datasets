require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/delete_job"
require "pathname"

module Datasets

  RSpec.describe DeleteJob do
    let(:volume) do
      {
        namespace: "test",
        id: "test_id",
        access_profile: :test_profile,
        right: :test_right
      }
    end
    let(:volume_writer) { double(:volume_writer, id: 75, delete: nil) }

    before(:each) do
      repo = double(:repo)
      Datasets.config.volume_writer_repo = repo
      allow(repo).to receive(:find).with(75).and_return(volume_writer)
    end

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

