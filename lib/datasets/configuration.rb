require "logger"
require "ostruct"
require "yaml"

module Datasets
  class Configuration < OpenStruct
    def initialize(hash = {})
      super hash.merge(logger: NullLogger.new)
    end

    def self.from_yaml(path)
      new(YAML.unsafe_load(File.read(path)))
    end

    private

    class NullLogger < Logger
      def initialize(*args)
      end

      def add(*args, &block)
      end
    end
  end
end
