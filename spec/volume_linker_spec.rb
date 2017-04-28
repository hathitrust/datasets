require_relative "./spec_helper"
require "volume_linker"
require "pathname"

module Datasets
  RSpec.describe VolumeLinker do
    let(:fs) do
      double(:fs,
        mkdir_p: nil,
        ln_s: nil,
        remove: nil,
        rm_empty_tree: nil
      )
    end
    let(:id) { :some_id }
    let(:dest_path) { Pathname.new("/dest/path/to/volume") }
    let(:dest_path_resolver) { double(:dpr, path: dest_path) }
    let(:volume_linker) { described_class.new(id: id, dest_path_resolver: dest_path_resolver, fs: fs) }

    describe "#id" do
      it "has an id" do
        expect(volume_linker.id).to_not be_nil
      end
    end

    describe "#save" do
      let(:volume) { double(:volume) }
      let(:src_path) { Pathname.new("/src/path/to/volume") }
      let(:path_from_dest_to_src) { Pathname.new "../../../src/path/to/volume" }
      before(:each) { volume_linker.save(volume, src_path) }
      it "creates the directory tree of the parent dir" do
        expect(fs).to have_received(:mkdir_p).with(dest_path.parent)
      end
      it "creates a link from src to dest" do
        expect(fs).to have_received(:ln_s).with(path_from_dest_to_src, dest_path)
      end
    end

    describe "#delete" do
      let(:volume) { double(:volume) }
      before(:each) { volume_linker.delete(volume) }
      it "deletes the link" do
        expect(fs).to have_received(:remove).with(dest_path)
      end
      it "deletes empty directory tree branches" do
        expect(fs).to have_received(:rm_empty_tree).with(dest_path.parent)
      end
    end

  end
end
