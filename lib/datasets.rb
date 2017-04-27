require "datasets/version"

require "datasets/configuration"
require "datasets/job"
require "datasets/filter"
require "datasets/filter/full_set_filter"
require "datasets/filter/pd_filter"
require "datasets/filter/pd_open_filter"
require "datasets/filter/pd_world_filter"
require "datasets/filter/pd_world_open_filter"
require "datasets/filesystem"
require "datasets/pairtree_path_resolver"
require "datasets/path_resolver"
require "datasets/report"
require "datasets/report_summary"
require "datasets/report_manager"
require "datasets/scheduler"
require "datasets/volume"
require "datasets/volume_creator"
require "datasets/volume_linker"
require "datasets/volume_writer"
require "datasets/zip_writer"
require "datasets/repository/feed_backend"
require "datasets/repository/rights_feed_volume_repo"
require "datasets/repository/rights_volume_repo"

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
