require_relative "./spec_helper"
require "pairtree_path_resolver"

RSpec.describe PairtreePathResolver do
  let(:parent_dir) { "/parent/dir" }
  let(:namespace) { "mdp" }
  let(:id) { "11223344556677" }
  let(:volume) { double(:volume, namespace: namespace, id: id)}

  describe "#path" do
    it "constructs the path from the volume" do
      resolver = described_class.new(parent_dir)
      expect(resolver.path(volume))
        .to eql Pathname.new(File.join(parent_dir, "obj", namespace, "pairtree_root", "11/22/33/44/55/66/77", id))
    end
  end
end
