require_relative "./spec_helper"
require "volume_linker"
require "pathname"

module Datasets
  RSpec.describe VolumeLinker do
    include_context "with mocked resque logger"

    let(:log_prefix) { "profile: some_id, volume: mocked_volume" }

    let(:fs) do
      double(:fs,
        mkdir_p: nil,
        rm_empty_tree: nil
      )
    end
    let(:id) { :some_id }
    let(:dest_path) { Pathname.new("/dest/path/to/volume") }
    let(:dest_path_resolver) { double(:dpr, path: dest_path) }
    let(:volume_linker) { described_class.new(id: id, dest_path_resolver: dest_path_resolver, fs: fs) }
    let(:volume) { double(:volume, to_s: "mocked_volume") }

    describe "#id" do
      it "has an id" do
        expect(volume_linker.id).to_not be_nil
      end
    end

    describe "#save" do
      let(:src_path) { Pathname.new("/src/path/to/volume") }
      let(:path_from_dest_to_src) { Pathname.new "../../../src/path/to/volume" }

      context "when the link is not already present" do
        before(:each) do
          allow(fs).to receive(:ln_s).and_return(true)
          volume_linker.save(volume, src_path)
        end

        it "creates the directory tree of the parent dir" do
          expect(fs).to have_received(:mkdir_p).with(dest_path.parent)
        end
        it "creates a link from src to dest" do
          expect(fs).to have_received(:ln_s).with(path_from_dest_to_src, dest_path)
        end
        it "logs the link creation" do
          expect(Resque.logger).to have_received(:info).with("#{log_prefix}: added")
        end
      end

      context "when the link is already present" do
        before(:each) do
          allow(fs).to receive(:ln_s).and_return(false)
          volume_linker.save(volume, src_path)
        end

        it "logs the no-op" do
          expect(Resque.logger).to have_received(:info).with("#{log_prefix}: already present")
        end
      end
    end

    describe "#delete" do
      context "when the link is present at removal time" do
        before(:each) do 
          allow(fs).to receive(:remove).and_return(true) 
          volume_linker.delete(volume)
        end

        it "deletes the link" do
          expect(fs).to have_received(:remove).with(dest_path)
        end
        it "deletes empty directory tree branches" do
          expect(fs).to have_received(:rm_empty_tree).with(dest_path.parent)
        end
        it "logs the deletion" do
          expect(Resque.logger).to have_received(:info).with("#{log_prefix}: removed")
        end
      end

      context "when the link is not present at removal time" do
        before(:each) do
          allow(fs).to receive(:remove).and_return(false)
          volume_linker.delete(volume)
        end

        it "logs the no-op" do
          expect(Resque.logger).to have_received(:info).with("#{log_prefix}: not present")
        end
      end
    end

  end
end
