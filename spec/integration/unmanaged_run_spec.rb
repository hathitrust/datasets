# frozen_string_literal: true
require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "superset creation with specified time range", integration: true do
    include_context "integration" do
      old_timestamp = Time.at(55)
      new_timestamp = Time.at(9999)
      time_range = Time.at(0)..Time.at(1000)

      subject { UnmanagedSafeRun.new(time_range).execute }

      context "no previous report exists" do
        context "volumes match rights profile" do
          context "dest empty" do
            include_context "with volume1 as", :ic, :open , new_timestamp
            include_context "with volume2 as", :pd, :google, old_timestamp
            include_context "with volume1 paths for", :full, "ht_text", new_timestamp
            include_context "with volume2 paths for", :full, "ht_text", old_timestamp
            include_context "relative report paths", time_range

            it "creates zips only for items before the end of the run's time range" do
              subject
              expect(files_from_zip(volume2_dest_zip)).to match_array volume2_zip_files
              expect(non_dir_files(full_root)).to match_array(
                  relative_volume2_dest_files
                  .concat relative_report_files
              )
            end

            it "writes a correct report for the given time range" do
              subject
              expect(File.read(full_root + saved_report).split("\n"))
                .to match_array [
                  "#{volume2_rights_tuple[:namespace]}.#{volume2_rights_tuple[:id]}"
                ]
              expect(File.read(full_root + deleted_report))
                .to be_empty
              expect(YAML.load_file(full_root + summary_report))
                .to eql(
                  { saved: 1, deleted: 0,
                    start_time: time_range.first, end_time: time_range.last
                  }
                )
            end
          end
        end
      end



    end
  end
end
