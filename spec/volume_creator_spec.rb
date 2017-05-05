# frozen_string_literal: true
require_relative "./spec_helper"
require "volume_creator"
require "pathname"

module Datasets
  RSpec.describe VolumeCreator do
    shared_examples_for "a volume creator" do |namespace, volume_id, pt_volume_id, pt_path|
      let(:fs) do
        double(:fs,
          mkdir_p: nil,
          ln_s: nil,
          remove: nil,
          rm_empty_tree: nil)
      end

      let(:volume) do
        double(:volume,
          namespace: namespace,
          id: volume_id)
      end

      let(:dest_path) { Pathname.new("/dest/#{pt_path}/#{volume_id}") }
      let(:src_path) { Pathname.new("/src/#{pt_path}/#{volume_id}") }
      let(:src_zip) { src_path + "#{pt_volume_id}.zip" }
      let(:dest_zip) { dest_path + "#{pt_volume_id}.zip" }
      let(:src_mets) { src_path + "#{pt_volume_id}.mets.xml" }
      let(:dest_mets) { dest_path + "#{pt_volume_id}.mets.xml" }

      let(:dest_path_resolver) { double(:dpr, path: dest_path) }

      let(:writer) { double(:writer, write: nil) }
      let(:vol_creator_id) { :some_id }
      let(:volume_creator) do
        described_class.new(
          id: vol_creator_id,
          dest_path_resolver: dest_path_resolver,
          writer: writer, fs: fs
        )
      end

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
        end
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
          it "does not create the zip" do
            expect(writer).to_not have_received(:write)
          end
        end
        context "destination zip present and older than src" do
          before(:each) do
            allow(fs).to receive(:exists?).with(dest_zip).and_return(true)
            allow(fs).to receive(:modify_time).with(src_zip).and_return(Time.at(9999))
            allow(fs).to receive(:modify_time).with(dest_zip).and_return(Time.at(0))
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
        end
      end

      describe "#delete" do
        before(:each) { volume_creator.delete(volume) }
        it "deletes the directory (and contents)" do
          expect(fs).to have_received(:remove).with(dest_path)
        end
        it "deletes empty directory tree branches" do
          expect(fs).to have_received(:rm_empty_tree).with(dest_path.parent)
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
