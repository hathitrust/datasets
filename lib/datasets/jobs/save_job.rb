require "datasets/job"
require "pathname"

module Datasets
  class SaveJob < Job
    def perform(volume_params, src_path, writer_id)
      volume = deserialize_volume(volume_params)
      src_path = Pathname.new(src_path)
      writer = Datasets.config.volume_writer[writer_id.to_sym]
      writer.save(volume, Pathname.new(src_path))
    end

    def self.serialize(volume, src_path, writer)
      [volume.to_h, src_path.to_s, writer.id.to_s]
    end
  end
end
