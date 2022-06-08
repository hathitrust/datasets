require "datasets/job"

module Datasets
  class DeleteJob < Job

    def perform(volume_params, writer_id)
      volume = deserialize_volume(volume_params)
      writer = Datasets.config.volume_writer[writer_id.to_sym]
      writer.delete(volume)
    end

    def self.serialize(volume, writer)
      [volume.to_h, writer.id.to_s]
    end

  end
end
