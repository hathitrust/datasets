require "datasets/version"

require "datasets/configuration"
require "datasets/filter"
require "datasets/filesystem"
require "datasets/pairtree_path_resolver"
require "datasets/path_resolver"
require "datasets/scheduler"
require "datasets/volume"
require "datasets/volume_creator"
require "datasets/volume_linker"
require "datasets/volume_writer"
require "datasets/zip_writer"

module Datasets
  class << self
    def config
      @config ||= Configuration.new
    end
    def config=(obj)
      @config = obj
    end
  end
end