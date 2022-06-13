# frozen_string_literal: true

require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "subset deletion", integration: true do
    include_context "integration" do
      old_timestamp = (Date.today - 7).to_time
      new_timestamp = (Date.today - 3).to_time

      let(:report_manager) { ReportManager.new(Datasets.config.report_dir[:pd], Filesystem.new) }
      subject do
        report_manager.build_next_report do |time_range|
          scheduler = Scheduler.new(
            src_path_resolver: Datasets.config.src_path_resolver[:pd],
            volume_writer: Datasets.config.volume_writer[:pd],
            filter: Datasets.config.filter[:pd],
            retriever: TimeRangeRetriever.new(
              time_range: time_range,
              repository: Datasets.config.volume_repo[:pd]
            )
          )
          [scheduler.add, scheduler.delete]
        end
      end

      context "no previous report exists" do
        context "a volume has mismatched rights" do
          include_context "with volume1 as", :ic, :open, old_timestamp
          include_context "with volume1 paths for", :pd, "ht_text_pd", old_timestamp
          include_context "relative report paths"
          before(:each) do
            volume1_dest_dir.mkpath
            FileUtils.touch(volume1_dest_zip, mtime: new_timestamp)
            FileUtils.touch(volume1_dest_mets, mtime: new_timestamp)
          end

          it "deletes the mismatched volume" do
            subject
            expect(volume1_dest_dir.exist?).to be false
          end

          it "writes a correct report from epoch until two days ago" do
            subject
            expect(File.read(pd_root + saved_report))
              .to be_empty
            expect(File.read(pd_root + deleted_report).split("\n"))
              .to match_array [
                "#{volume1_rights_tuple[:namespace]}.#{volume1_rights_tuple[:id]}"
              ]
            expect(YAML.unsafe_load_file(pd_root + summary_report))
              .to eql(
                {saved: 0, deleted: 1,
                 start_time: Time.at(0), end_time: two_days_ago}
              )
          end
        end
      end
    end
  end
end
