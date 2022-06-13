require_relative "./spec_helper"
require "pairtree_path_resolver"

module Datasets
  RSpec.describe PairtreePathResolver do
    let(:parent_dir) { "/parent/dir" }
    let(:resolver) { described_class.new(parent_dir) }
    let(:volume) { double(:volume, namespace: namespace, id: id) }

    describe "#path" do
      context "with a barcode id" do
        let(:namespace) { "mdp" }
        let(:id) { "39015012345678" }

        it "constructs the path from the volume" do
          expect(resolver.path(volume))
            .to eql Pathname.new(File.join(parent_dir, "obj", namespace,
              "pairtree_root", "39/01/50/12/34/56/78", id))
        end
      end

      context "with an arkid" do
        let(:namespace) { "loc" }
        let(:id) { "ark:/13960/t7jq2979w" }

        it "constructs the path from the volume" do
          expect(resolver.path(volume))
            .to eql Pathname.new(File.join(parent_dir, "obj", namespace,
              "pairtree_root", "ar/k+/=1/39/60/=t/7j/q2/97/9w", "ark+=13960=t7jq2979w"))
        end
      end
    end
  end
end
