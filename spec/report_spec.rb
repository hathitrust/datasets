require_relative "./spec_helper"
require "report"
require "report_summary"
require "pathname"

module Datasets

  RSpec.describe Report do
    let(:saved_volumes) do
      [
        double(:v1, id: "001", namespace: "saved"),
        double(:v1, id: "002", namespace: "saved"),
        double(:v1, id: "003", namespace: "saved")
      ]
    end
    let(:deleted_volumes) do
      [
        double(:v1, id: "001", namespace: "deleted"),
        double(:v1, id: "002", namespace: "deleted"),
        double(:v1, id: "003", namespace: "deleted")
      ]
    end
    let(:time_range) { Time.at(0)..Time.at(1000) }
    let(:fs) { double(:fs, write: nil, mkdir_p: nil) }
    let(:report) { described_class.new(saved_volumes, deleted_volumes, time_range, fs) }

    describe "#save" do
      let(:dir) { Pathname.new("some/dir") }
      let(:summary) { double(:summary, to_h: {some: "hash"}) }
      before(:each) { allow(ReportSummary).to receive(:new).and_return(summary) }
      it "creates the directory" do
        expect(fs).to receive(:mkdir_p).with dir
        report.save(dir)
      end
      it "writes the saved volumes to dir/saved.txt" do
        expect(fs).to receive(:write).with(
          dir + "saved.txt",
          saved_volumes.map{|v| "#{v.namespace}.#{v.id}"}.join("\n")
        )
        report.save(dir)
      end
      it "writes the deleted volumes to dir/deleted.txt" do
        expect(fs).to receive(:write).with(
          dir + "deleted.txt",
          deleted_volumes.map{|v| "#{v.namespace}.#{v.id}"}.join("\n")
        )
        report.save(dir)
      end
      it "writes a summary to dir/summary.yml" do
        expect(fs).to receive(:write).with(
          dir + "summary.yml",
          summary.to_h.to_yaml
        )
        report.save(dir)
      end
    end
    
    describe "#summary" do
      before(:each) { allow(ReportSummary).to receive(:new) }
      it "returns a ReportSummary" do
        report.summary
        expect(ReportSummary).to have_received(:new).with(
          saved_volumes.size,
          deleted_volumes.size,
          time_range,
          fs)
      end
    end

    describe "#started" do
      it "returns the start of the period" do
        expect(report.started).to eql(time_range.first)
      end
    end

    describe "#ended" do
      it "returns the end of the period" do
        expect(report.ended).to eql(time_range.last)
      end
    end
    
    
  end


end