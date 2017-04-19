require "datasets"

module Datasets
  class DeleteJob < Job
    @queue = :all

    def initialize(volume, writer)
      @volume = volume
      @writer = writer
    end

    def perform
      writer.delete(volume)
    end

    def serialize
      [volume.to_h, writer.id]
    end

    def self.deserialize(volume, writer_id)
      new(
        deserialize_volume(volume),
        Datasets.config.volume_writer[writer_id.to_sym]
      )
    end

    private
    attr_accessor :volume, :writer
  end
end
