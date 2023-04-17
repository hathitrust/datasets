# frozen_string_literal: true

require_relative "./spec_helper"
require "safe_run"

module Datasets
  RSpec.describe SafeRun do
    it "raises an error when the queue is not empty" do
      allow_any_instance_of(Sidekiq::RetrySet).to receive(:size).and_return(5)
      expect { SafeRun.new.execute }.to raise_error(/Queue is not empty/)
    end
  end
end
