require_relative "../spec_helper"
require_relative "../job_helper"
require "datasets/job"
require "json"

module Datasets

  shared_examples "a job" do
    let(:queue) { :test }

    it "#serialize returns an array" do
      expect(described_class.serialize(*params)).to be_an Array
    end

    it "is performed when enqueued" do
      expect_any_instance_of(described_class).to receive(:perform).once
      described_class.enqueue(*params)
    end
  end

end
