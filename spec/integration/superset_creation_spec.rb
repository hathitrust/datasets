# frozen_string_literal: true
require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "superset creation", integration: true do
    include_context "integration" do
      old_timestamp = Time.at(55)
      new_timestamp = Time.at(9999)

      let(:report_manager) { ReportManager.new(Datasets.config.report_dir[:full], Filesystem.new) }
      subject do
        report_manager.build_next_report do |time_range|
          scheduler = Scheduler.new(
            src_path_resolver: Datasets.config.src_path_resolver[:full],
            volume_writer: Datasets.config.volume_writer[:full],
            filter: Datasets.config.filter[:full],
            retriever: TimeRangeRetriever.new(
              time_range: time_range,
              repository: Datasets.config.volume_repo[:full])
          )
          [scheduler.add, scheduler.delete]
        end
      end

      context "no previous report exists" do
        context "volumes match rights profile" do
          context "dest empty" do
            include_context "with volume1 as", :ic, :open , new_timestamp
            include_context "with volume2 as", :pd, :google, old_timestamp
            include_context "with volume1 paths for", :full, "ht_text", new_timestamp
            include_context "with volume2 paths for", :full, "ht_text", old_timestamp
            include_context "relative report paths"
            it "creates zips in the full set containing the expected files" do
              subject
              expect(files_from_zip(volume1_dest_zip)).to match_array volume1_zip_files
              expect(files_from_zip(volume2_dest_zip)).to match_array volume2_zip_files
              expect(non_dir_files(full_root)).to match_array(
                relative_volume1_dest_files
                  .concat relative_volume2_dest_files
                  .concat relative_report_files
              )
            end

            it "writes a correct report from epoch until now" do
              subject
              expect(File.read(full_root + saved_report).split("\n"))
                .to match_array [
                  "#{volume1_rights_tuple[:namespace]}.#{volume1_rights_tuple[:id]}",
                  "#{volume2_rights_tuple[:namespace]}.#{volume2_rights_tuple[:id]}"
                ]
              expect(File.read(full_root + deleted_report))
                .to be_empty
              expect(YAML.load_file(full_root + summary_report))
                .to eql(
                  { saved: 2, deleted: 0,
                    start_time: Time.at(0), end_time: two_days_ago
                  }
                )
            end
          end

          context "dest contains up-to-date zip and outdated zip" do
            include_context "with volume1 as", :ic, :open , new_timestamp
            include_context "with volume2 as", :pd, :google, new_timestamp
            include_context "with volume1 paths for", :full, "ht_text", new_timestamp
            include_context "with volume2 paths for", :full, "ht_text", new_timestamp
            include_context "relative report paths"
            let(:up_to_date_volume) { volume1 }
            let(:up_to_date_zip) { volume1_dest_zip }
            let(:outdated_volume) { volume2 }
            let(:outdated_zip) { volume2_dest_zip }
            before(:each) do
              volume1_dest_dir.mkpath
              volume2_dest_dir.mkpath
              FileUtils.touch(up_to_date_zip, mtime: new_timestamp)
              FileUtils.touch(outdated_zip, mtime: old_timestamp)
            end

            it "updates an existing volume" do
              subject
              expect(outdated_zip.mtime).to be > new_timestamp
              expect(files_from_zip(outdated_zip)).to match_array volume2_zip_files
              expect(up_to_date_zip.size).to eql(0)
            end

            it "writes a correct report from epoch until two days ago" do
              subject
              expect(File.read(full_root + saved_report).split("\n"))
                .to match_array [
                  "#{volume1_rights_tuple[:namespace]}.#{volume1_rights_tuple[:id]}",
                  "#{volume2_rights_tuple[:namespace]}.#{volume2_rights_tuple[:id]}"
                ]
              expect(File.read(full_root + deleted_report))
                .to be_empty
              expect(YAML.load_file(full_root + summary_report))
                .to eql(
                  { saved: 2, deleted: 0,
                    start_time: Time.at(0), end_time: two_days_ago
                  }
                )
            end
          end
        end
      end



    end
  end
end
