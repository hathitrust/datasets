require "datasets"
require_relative "../../config/hathitrust_config"

module Datasets
  class DedupeDeleteLog
    attr_reader :profile
    attr_reader :files

    def initialize(files)
      @files = files
    end

    def compile_results
      # Files should be small, so fine to read them all into memory
      files.flat_map { |f| File.readlines(f) }
        .map(&:strip)
        .sort
        .uniq
        .map(&:split)
        .select { |profile, id| not_in_dataset(profile, id) }
        .group_by { |profile, id| profile }
        # transform "pd" => [ ["pd", "id1"], ["pd", "id2" ] ] to
        # "pd" => ["id1", "id2"]
        .transform_values do |deletes|
          deletes.map { |profile, id| id }.sort
        end
    end

    def not_in_dataset(profile, id)
      (namespace, id) = id.split(".", 2)
      path_resolver = Datasets.config.dest_path_resolver[profile.to_sym]
      volume = Volume.new(namespace: namespace, id: id, access_profile: :none, right: :none)
      !File.exist?(path_resolver.path(volume))
    end

    private

    attr_reader :path_resolver
  end
end
