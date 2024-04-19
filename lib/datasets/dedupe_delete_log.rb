module Datasets
  class DedupeDeleteLog
    attr_reader :profile
    attr_reader :files

    def initialize(profile:, files:)
      @profile = profile
      @files = files
      @path_resolver = Datasets.config.dest_path_resolver[profile]
    end

    def compile_results
      Tempfile.create("dedupe-deletes") do |f|
        filename = f.path
        f.close
        system("sort #{files.join(" ")} | uniq > #{filename}")
        f = File.open(filename)
        yield f.map(&:strip).select { |id| not_in_dataset(id) }
      end
    end

    def not_in_dataset(id)
      (namespace, id) = id.split(".", 2)
      volume = Volume.new(namespace: namespace, id: id, access_profile: :none, right: :none)
      !File.exist?(path_resolver.path(volume))
    end

    private

    attr_reader :path_resolver
  end
end
