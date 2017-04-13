require_relative "./spec_helper"
require "volume_creator"
require "pathname"

module Datasets
  RSpec.describe VolumeCreator do
    let(:volume) do
      double(:volume,
        namespace: "mdp",
        id: "112233445566"
      )
    end
    let(:dest_path) { Pathname.new("/dest/path/to/11/22/33/44/55/66") }

    let(:fs) do
      double(:fs,
        mkdir_p: nil,
        ln_s: nil,
        remove: nil,
        rm_empty_tree: nil
      )
    end
    let(:id) { :some_id }
    let(:dest_path_resolver) { double(:dpr, path: dest_path) }
    let(:writer) { double(:writer, write: nil) }
    let(:volume_creator) do
      described_class.new(
        id: id,
        dest_path_resolver: dest_path_resolver,
        writer: writer, fs: fs)
    end

    describe "#id" do
      it "has an id" do
        expect(volume_creator.id).to_not be_nil
      end
    end

    describe "#save" do
      let(:src_path) { Pathname.new("/src/path/to/volume") }
      let(:src_zip) { src_path + "#{volume.id}.zip" }
      let(:dest_zip) { dest_path + "#{volume.id}.zip" }
      let(:src_mets) { src_path + "#{volume.id}.mets" }
      let(:dest_mets) { dest_path + "#{volume.id}.mets" }


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
          allow(fs).to receive(:creation_time).with(src_zip).and_return(Time.at(0))
          allow(fs).to receive(:creation_time).with(dest_zip).and_return(Time.at(9999))
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
          allow(fs).to receive(:creation_time).with(src_zip).and_return(Time.at(9999))
          allow(fs).to receive(:creation_time).with(dest_zip).and_return(Time.at(0))
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
end
