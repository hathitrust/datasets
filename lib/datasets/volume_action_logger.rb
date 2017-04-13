# frozen_string_literal: true
module Datasets
  class VolumeActionLogger
    def initialize(io)
      @io = io
    end

    def log(action, volume, path)
      io.puts([Time.now.iso8601, action, volume, path]
        .join(" "))
    end

    private

    attr_reader :io
  end
end
