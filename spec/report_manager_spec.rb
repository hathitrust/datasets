require_relative "./spec_helper"
require "report_manager"
require "pathname"

module Datasets

  RSpec.describe ReportManager do
    let(:parent_dir) { Pathname.new("some/dir") }
    let(:fs) { double(:fs, mkdir_p: nil, read: nil, write: nil, exists?: true) }
    let(:mgr) { described_class.new(parent_dir, fs) }

    describe "#last_range" do
      let(:last_range) { Time.new(2017,05,20,01,30,00,"-05:00")..Time.new(2017,05,21,01,29,59,"-05:00") }
      it "returns the time range for the most recent report" do
        manager = described_class.new(fixtures_dir + "report_test", Filesystem.new)
        expect(manager.last_range).to eql last_range
      end
      it "returns a time range ending in epoch when no reports are present" do
        Dir.mktmpdir do |dir|
          manager = described_class.new(Pathname.new(dir), Filesystem.new)
          expect(manager.last_range.last).to eql(Time.at(0))
        end
      end
    end

    # We mock #last_range here because it is convenient and should
    # help to isolate errors.
    describe "#build_next_report" do
      let(:saved_volumes) { [1,2] }
      let(:deleted_volumes) { [3,4,5] }
      let(:last_range) { Time.new(2001, 1, 1)..Time.new(2001, 1, 3, 6, 30, 25) }
      let(:new_range) { last_range.last..Time.new(2001, 1, 5, 14, 21, 0) }
      let(:report) { double(:report, save: nil) }
      before(:each) do
        allow(Report).to receive(:new).and_return(report)
        allow(mgr).to receive(:last_range).and_return(last_range)
        allow(Time).to receive(:now).and_return(new_range.last)
      end
      it "yields a period of last_range.last..Time.now" do
        expect{|spy|
          mgr.build_next_report(&spy)
        }.to yield_with_args(new_range)
      end
      it "creates the report described by the block" do
        expect(Report).to receive(:new).with(saved_volumes, deleted_volumes, new_range, fs)
        mgr.build_next_report { [saved_volumes, deleted_volumes] }
      end
      it "saves the report at parent_dir/YYYYMMDDHHMMSS-YYYMMDDHHMMSS/" do
        expect(report).to receive(:save).with(parent_dir + "20010103063025-20010105142100")
        mgr.build_next_report { [saved_volumes, deleted_volumes] }
      end
    end

  end

end