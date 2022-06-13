# frozen_string_literal: true

require_relative "./spec_helper"
require "volume_creator"
require "pathname"

module Datasets
  RSpec.describe VolumeCreator do
    shared_examples_for "a volume creator" do |namespace, volume_id, pt_volume_id, pt_path|
      # needed to pass through to shared context
      let(:namespace) { namespace }
      let(:volume_id) { volume_id }
      let(:pt_volume_id) { pt_volume_id }
      let(:pt_path) { pt_path }
      let(:today) { Date.today.to_time }
      let(:two_days_ago) { (Date.today - 2).to_time }

      include_context "with mocked sidekiq logger"
      include_context "with volume creator fixtures"

      describe "#id" do
        it "has an id" do
          expect(volume_creator.id).to_not be_nil
        end
      end

      describe "#save" do
        context "destination zip not present" do
          before(:each) do
            allow(fs).to receive(:exists?).with(dest_zip).and_return(false)
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
          it "logs creating the zip" do
            expect(Sidekiq.logger).to have_received(:info).with("#{log_prefix}: updated")
          end
        end
        context "destination zip present and newer than src" do
          before(:each) do
            allow(fs).to receive(:exists?).with(dest_zip).and_return(true)
            allow(fs).to receive(:modify_time).with(src_zip).and_return(two_days_ago)
            allow(fs).to receive(:modify_time).with(dest_zip).and_return(today)
            volume_creator.save(volume, src_path)
          end
          it "creates the directory tree including final dir" do
            expect(fs).to have_received(:mkdir_p).with(dest_path)
          end
          it "links the mets" do
            expect(fs).to have_received(:ln_s).with(src_mets, dest_mets)
          end
          it "does not create the zip" do
            expect(writer).to_not have_received(:write)
          end
          it "logs that destination zip was newer than src" do
            expect(Sidekiq.logger).to have_received(:info).with("#{log_prefix}: up to date")
          end
        end
        context "destination zip present and older than src" do
          before(:each) do
            allow(fs).to receive(:exists?).with(dest_zip).and_return(true)
            allow(fs).to receive(:modify_time).with(src_zip).and_return(today)
            allow(fs).to receive(:modify_time).with(dest_zip).and_return(two_days_ago)
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
          it "logs the update" do
            expect(Sidekiq.logger).to have_received(:info).with("#{log_prefix}: updated")
          end
        end
      end

      describe "#delete" do
        context "destination zip present at removal time" do
          before(:each) do
            allow(fs).to receive(:remove).with(dest_path).and_return(true)
            volume_creator.delete(volume)
          end
          it "logs the removal" do
            expect(Sidekiq.logger).to have_received(:info).with("#{log_prefix}: removed")
          end
          it "deletes the directory (and contents)" do
            expect(fs).to have_received(:remove).with(dest_path)
          end
          it "deletes empty directory tree branches" do
            expect(fs).to have_received(:rm_empty_tree).with(dest_path.parent)
          end
        end

        context "destination zip not present at removal time" do
          before(:each) do
            allow(fs).to receive(:remove).with(dest_path).and_return(false)
            volume_creator.delete(volume)
          end
          it "logs that it was already removed" do
            expect(Sidekiq.logger).to have_received(:info).with("#{log_prefix}: not present")
          end
        end
      end
    end

    context "with a barcode id" do
      it_behaves_like "a volume creator", "mdp", "39015012345678",
        "39015012345678", "mdp/39/01/50/12/34/56/78"
    end

    context "with an arkid" do
      it_behaves_like "a volume creator", "loc", "ark:/13960/t7jq2979w",
        "ark+=13960=t7jq2979w", "loc/pairtree_root/ar/k+/=1/39/60/=t/7j/q2/97/9w"
    end
  end
end
