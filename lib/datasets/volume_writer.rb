# Writes and deletes volumes within the superset.
class VolumeWriter

  # Save a volume to the filesystem.  This is
  # an idempotent operation.
  # @param [Volume] volume
  # @param [Pathname] src_path Path to the volume's source directory.
  def save(volume, src_path); end

  # Delete a volume from the filesystem.  This is
  # an idempotent operation.
  # @param [Volume] volume
  def delete(volume); end

end