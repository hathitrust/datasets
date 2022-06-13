require "datasets/path_resolver"
require "pairtree"
require "pathname"

module Datasets
  class PairtreePathResolver < PathResolver
    def initialize(parent_dir)
      @parent_dir = Pathname.new(parent_dir)
    end

    def path(volume)
      parent_dir + "obj" + volume.namespace + "pairtree_root" + Pairtree::Path.id_to_path(volume.id)
    end

    private

    attr_reader :parent_dir
  end
end
