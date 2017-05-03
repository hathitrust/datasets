# frozen_string_literal: true
require_relative "./spec_helper"
require "scheduler"

module Datasets
  RSpec.describe Scheduler do
    let(:repo) { double(:repo) }
    let(:src) { double(:src_path_resovler) }
    let(:writer) { double(:writer) }
    let(:filter) { double(:filter) }
    let(:start_time) { Time.local(2017, 1, 12) }
    let(:end_time) { Time.now }
    let(:log) { StringIO.new }
    let(:scheduler) do
      described_class.new(
        volume_repo: repo, src_path_resolver: src,
        volume_writer: writer, filter: filter,
        time_range: start_time..end_time
      )
    end
    let(:in_volumes) { [double(:v1), double(:v2), double(:v3)] }
    let(:src_paths) { [:path1, :path2, :path3] }
    let(:out_volumes) { [double(:v4), double(:v5)] }
    let(:create_job) { double(:create_job) }
    let(:delete_job) { double(:delete_job) }

    before(:each) do
      allow(repo).to receive(:changed_between).with(start_time, anything)
        .and_return(in_volumes + out_volumes)

      allow(src).to receive(:path).and_return(*src_paths)
      allow(Datasets::SaveJob).to receive(:new).and_return(create_job)
      allow(create_job).to receive(:enqueue)

      allow(delete_job).to receive(:enqueue)
      allow(Datasets::DeleteJob).to receive(:new).and_return(delete_job)

      in_volumes.each {|v| allow(filter).to receive(:matches?).with(v).and_return(true) }
      out_volumes.each {|v| allow(filter).to receive(:matches?).with(v).and_return(false) }
    end

    describe "#add" do
      it "enqueues a Datasets::SaveJob for each volume that satisfies the filter" do
        expect(create_job).to receive(:enqueue).exactly(in_volumes.count).times

        scheduler.add
      end

      it "passes each volume and its path to the job" do
        in_volumes.zip(src_paths).each do |volume, path|
          expect(Datasets::SaveJob).to receive(:new)
            .with(volume, path, anything)
        end

        scheduler.add
      end

      it "passes the volume_writer to each Datasets::SaveJob" do
        expect(Datasets::SaveJob).to receive(:new).with(anything, anything, writer)
          .exactly(in_volumes.count).times

        scheduler.add
      end

      it "returns the enqueued volumes" do
        expect(scheduler.add).to eql(in_volumes)
      end

    end

    describe "#delete" do
      it "enqueues a Datasets::DeleteJob for each volume that does not satisfy the filter" do
        expect(delete_job).to receive(:enqueue).exactly(out_volumes.count).times

        scheduler.delete
      end

      it "passes the volume to the job" do
        out_volumes.each do |volume|
          expect(Datasets::DeleteJob).to receive(:new)
            .with(volume, anything)
        end

        scheduler.delete
      end

      it "passes the volume_writer to each Datasets::DeleteJob" do
        expect(Datasets::DeleteJob).to receive(:new).with(anything, writer)
          .exactly(out_volumes.count).times

        scheduler.delete
      end

      it "returns the enqueued volumes" do
        expect(scheduler.delete).to eql(out_volumes)
      end

    end
  end
end
