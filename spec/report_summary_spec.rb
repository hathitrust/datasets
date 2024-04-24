require_relative "spec_helper"
require "report_summary"

module Datasets
  RSpec.describe ReportSummary do
    let(:num_saved) { 55 }
    let(:num_deleted) { 1031 }
    let(:time_range) { Time.at(0)..Time.at(1000) }
    let(:fs) { double(:fs, write: nil, mkdir_p: nil) }
    let(:summary) { described_class.new(num_saved, num_deleted, time_range, fs) }

    describe "#to_h" do
      it "can be converted to a hash" do
        expect(summary.to_h).to eql(
          {
            start_time: time_range.first,
            end_time: time_range.last,
            saved: num_saved,
            deleted: num_deleted
          }
        )
      end
    end

    describe "#started" do
      it "returns the start of the period" do
        expect(summary.started).to eql(time_range.first)
      end
    end

    describe "#ended" do
      it "returns the end of the period" do
        expect(summary.ended).to eql(time_range.last)
      end
    end
  end
end
