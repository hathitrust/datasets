# frozen_string_literal: true
require "spec_helper"
require "job_helper"
require "datasets"
require_relative "../../config/hathitrust_config"
require "yaml"
require "fileutils"

module Datasets
  RSpec.describe "force update", integration: true do
    include_context "integration" do
      old_timestamp = Time.at(55)
      new_timestamp = Time.at(9999)

      let(:htids) { ['test.001','test.002' ] }
      subject { HTIDSafeRun.new(htids).queue_and_report(:force_full) }
      
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

        it "updates all given volumes" do
          subject
          expect(up_to_date_zip.mtime).to be > new_timestamp
          expect(files_from_zip(up_to_date_zip)).to match_array volume1_zip_files
          expect(outdated_zip.mtime).to be > new_timestamp
          expect(files_from_zip(outdated_zip)).to match_array volume2_zip_files
        end

      end

    end
  end
end
