# frozen_string_literal: true
require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "subset creation", integration: true do
    include_context "integration" do
      old_timestamp = Time.at(55)
      new_timestamp = Time.at(9999)

      let(:report_manager) { ReportManager.new(Datasets.config.report_dir[:pd_world_open], Filesystem.new) }
      subject do
        report_manager.build_next_report do |time_range|
          scheduler = Scheduler.new(
            volume_repo: Datasets.config.volume_repo[:pd_world_open],
            src_path_resolver: Datasets.config.src_path_resolver[:pd_world_open],
            volume_writer: Datasets.config.volume_writer[:pd_world_open],
            filter: Datasets.config.filter[:pd_world_open],
            time_range: time_range
          )
          [scheduler.add, scheduler.delete]
        end
      end
      let(:report) { subject }

      context "no previous report exists" do
        context "volumes match rights profile" do
          context "dest empty" do
            include_context "with volume1 as", :pd, :open , new_timestamp
            include_context "with volume2 as", :"cc-zero", :open, old_timestamp
            include_context "with volume1 paths for", :pd_world_open, "ht_text_pd_world_open_access", new_timestamp
            include_context "with volume2 paths for", :pd_world_open, "ht_text_pd_world_open_access", old_timestamp
            include_context "relative report paths"
            let(:volume1_superset_src_dir) { datasets_root + "ht_text" + pairtree_prefix + "00" + "1" + "001" }
            let(:volume2_superset_src_dir) { datasets_root + "ht_text" + pairtree_prefix + "00" + "2" + "002" }
            before(:each) do
              volume1_superset_src_dir.mkpath
              FileUtils.cp fixtures_dir + "text_only_test_volume.zip", volume1_superset_src_dir + "001.zip"
              FileUtils.touch volume1_superset_src_dir + "001.mets.xml"
              volume2_superset_src_dir.mkpath
              FileUtils.cp fixtures_dir + "text_only_test_volume.zip", volume2_superset_src_dir + "002.zip"
              FileUtils.touch volume2_superset_src_dir + "002.mets.xml"
            end
            it "creates zips in the pd_world_open set containing the expected files" do
              subject
              expect(files_from_zip(volume1_dest_zip)).to match_array volume1_zip_files
              expect(files_from_zip(volume2_dest_zip)).to match_array volume2_zip_files
              expect(non_dir_files(pd_world_open_root)).to match_array(
                relative_volume1_dest_files
                  .concat relative_volume2_dest_files
                  .concat relative_report_files
              )
            end

            it "writes a correct report from epoch until now" do
              subject
              expect(File.read(pd_world_open_root + saved_report).split("\n"))
                .to match_array [
                  "#{volume1_rights_tuple[:namespace]}.#{volume1_rights_tuple[:id]}",
                  "#{volume2_rights_tuple[:namespace]}.#{volume2_rights_tuple[:id]}"
                ]
              expect(File.read(pd_world_open_root + deleted_report))
                .to be_empty
              expect(YAML.load_file(pd_world_open_root + summary_report))
                .to eql(
                  { saved: 2, deleted: 0,
                    start_time: Time.at(0), end_time: Time.now
                  }
                )
            end
          end

        end
      end

    end
  end
end
