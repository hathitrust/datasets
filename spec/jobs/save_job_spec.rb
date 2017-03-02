require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/save_job"
require "pathname"

module Datasets

  RSpec.describe SaveJob do
    let(:volume) do
      {
        namespace: "test",
        id: "test_id",
        access_profile: :test_profile,
        right: :test_right
      }
    end
    let(:src_path) { Pathname.new("some/path")}
    let(:volume_writer) { double(:volume_writer, id: 75, save: nil) }

    before(:each) do
      repo = double(:repo)
      Datasets.config.volume_writer_repo = repo
      allow(repo).to receive(:find).with(75).and_return(volume_writer)
    end

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

