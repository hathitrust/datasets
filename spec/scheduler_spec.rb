# frozen_string_literal: true
require_relative "./spec_helper"
require "scheduler"

module Datasets
  RSpec.describe Scheduler do

    let(:src) { double(:src_path_resovler) }
    let(:writer) { double(:writer) }
    let(:filter) { double(:filter) }
    let(:log) { StringIO.new }
    let(:scheduler) do
      described_class.new(
        src_path_resolver: src,
        volume_writer: writer, filter: filter,
        retriever: retriever,
        save_job: save_job,
        delete_job: delete_job
      )
    end
    let(:in_volumes) { [double(:v1), double(:v2), double(:v3)] }
    let(:src_paths) { [:path1, :path2, :path3] }
    let(:out_volumes) { [double(:v4), double(:v5)] }
    let(:retriever) { double(:retriever) }
    let(:save_job) { class_double(Datasets::SaveJob, enqueue: true) }
    let(:delete_job) { class_double(Datasets::DeleteJob, enqueue: true) }

    before(:each) do
      allow(retriever).to receive(:retrieve)
        .and_return(in_volumes + out_volumes)

      allow(src).to receive(:path).and_return(*src_paths)

      in_volumes.each {|v| allow(filter).to receive(:matches?).with(v).and_return(true) }
      out_volumes.each {|v| allow(filter).to receive(:matches?).with(v).and_return(false) }
    end

    describe "#add" do
      it "enqueues a Datasets::SaveJob for each volume that satisfies the filter" do
        expect(save_job).to receive(:enqueue).exactly(in_volumes.count).times

        scheduler.add
      end

      it "passes each volume and its path to the job" do
        in_volumes.zip(src_paths).each do |volume, path|
          expect(save_job).to receive(:enqueue)
            .with(volume, path, anything)
        end

        scheduler.add
      end

      it "passes the volume_writer to each Datasets::SaveJob" do
        expect(save_job).to receive(:enqueue).with(anything, anything, writer)
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
          expect(delete_job).to receive(:enqueue)
            .with(volume, anything)
        end

        scheduler.delete
      end

      it "passes the volume_writer to each Datasets::DeleteJob" do
        expect(delete_job).to receive(:enqueue).with(anything, writer)
          .exactly(out_volumes.count).times

        scheduler.delete
      end

      it "returns the enqueued volumes" do
        expect(scheduler.delete).to eql(out_volumes)
      end

    end
  end
end
