require_relative "../spec_helper"
require_relative "../job_helper"
require "jobs/scheduler_job"
require "pathname"

module Datasets

  RSpec.describe SchedulerJob do
    include_context "with mocked resque logger"
    let(:profile) { :pd }

    it_behaves_like "a job" do
      let(:job) { described_class.new(profile) }
    end
  end

end

