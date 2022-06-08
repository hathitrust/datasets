# Writes and deletes volumes within the superset.
module Datasets
  class VolumeWriter

    # The id of this writer, generally a symbol or number.
    def id; end

    # Save a volume to the filesystem.  This is
    # an idempotent operation.
    # @param [Volume] volume
    # @param [Pathname] src_path Path to the volume's source directory.
    def save(volume, src_path); end

    # Delete a volume from the filesystem.  This is
    # an idempotent operation.
    # @param [Volume] volume
    def delete(volume); end

    def log(volume,action)
      Sidekiq.logger.info("profile: #{id}, volume: #{volume}: #{action}")
    end

  end
end
