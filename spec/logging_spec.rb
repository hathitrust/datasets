# frozen_string_literal: true
require "spec_helper"
require "datasets/volume_action_logger"

module Datasets
  ISO8601_REGEX = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}'
  TEST_VOLUME_PATH = "/path/to/test.1234"
  RSpec.describe VolumeActionLogger do
    let(:output) { StringIO.new }
    let(:logger) { VolumeActionLogger.new(output) }
    let(:volume) { Volume.new(namespace: "test", id: "1234", access_profile: :open, right: :pd) }

    describe "#new" do
      it "accepts an IO object" do
        expect(logger).not_to be_nil
      end
    end

    describe "#log" do
      it "outputs a timestamp, the action, the volume ID, and its corresponding path" do
        logger.log(:save, volume, TEST_VOLUME_PATH)
        expect(output.string).to match(/^#{ISO8601_REGEX} save test.1234 pd open #{TEST_VOLUME_PATH}$/)
      end
    end
  end
end
