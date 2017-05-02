require "datasets/job"
require "pathname"

module Datasets
  class SaveJob < Job

    # @param volume [Volume]
    # @param src_path [Pathname]
    # @param writer [VolumeWriter]
    def initialize(volume, src_path, writer)
      @volume = volume
      @src_path = src_path
      @writer = writer
    end

    def perform
      writer.save(volume, Pathname.new(src_path))
    end

    def serialize
      [volume.to_h, src_path.to_s, writer.id]
    end

    def self.deserialize(volume, src_path, writer_id)
      new(
        deserialize_volume(volume),
        Pathname.new(src_path),
        Datasets.config.volume_writer[writer_id.to_sym]
      )
    end

    private
    attr_accessor :volume, :src_path, :writer
  end
end
