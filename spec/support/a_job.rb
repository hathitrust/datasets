require_relative "../spec_helper"
require_relative "../job_helper"
require "datasets/job"

module Datasets

  shared_examples "a job" do
    let(:queue) { :test }
    it "#serialize returns an array" do
      expect(job.serialize).to be_an Array
    end
    it "responds to ::deserialize" do
      expect(described_class.respond_to?(:deserialize)).to be true
    end
    it "can serialize and deserialize itself" do
      reified_instance = described_class.deserialize(*job.serialize)
      expect(reified_instance.serialize).to eql(job.serialize)
    end
    it "survives being enqueued" do
      expect_any_instance_of(described_class).to receive(:perform).once
      job.enqueue(queue)
    end
    it "survives jsonification" do
      json = JSON.dump(job.serialize)
      reified_instance = described_class.deserialize(*JSON.parse(json))
      expect(reified_instance.serialize).to eql(job.serialize)
    end
    it "can be enqueued with #enqueue" do
      expect(Resque::Job).to receive(:create).with(queue, described_class, job.serialize)
      job.enqueue(queue)
    end
  end

end
