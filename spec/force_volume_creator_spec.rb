# frozen_string_literal: true
require_relative "./spec_helper"
require "force_volume_creator"
require "pathname"

module Datasets
  RSpec.describe ForceVolumeCreator do
    let(:namespace) { "mdp" }
    let(:volume_id) { "39015012345678" }
    let(:pt_volume_id) { "39015012345678" }
    let(:pt_path) { "mdp/39/01/50/12/34/56/78" }

    include_context "with mocked resque logger"
    include_context "with volume creator fixtures"

    describe "#save" do
      context "destination zip present and newer than src" do
        before(:each) do
          allow(fs).to receive(:exists?).with(dest_zip).and_return(true)
          allow(fs).to receive(:modify_time).with(src_zip).and_return(Time.at(0))
          allow(fs).to receive(:modify_time).with(dest_zip).and_return(Time.at(9999))
          volume_creator.save(volume, src_path)
        end
        it "creates the directory tree including final dir" do
          expect(fs).to have_received(:mkdir_p).with(dest_path)
        end
        it "links the mets" do
          expect(fs).to have_received(:ln_s).with(src_mets, dest_mets)
        end
        it "creates the zip" do
          expect(writer).to have_received(:write).with(src_zip, dest_zip)
        end
        it "logs that destination zip was updated" do
          expect(Resque.logger).to have_received(:info).with("#{log_prefix}: updated")
        end
      end
    end
  end
end
