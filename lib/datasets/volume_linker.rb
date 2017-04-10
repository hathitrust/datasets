# Writes and deletes symlinks within the subsets
# to the superset.
class VolumeLinker

  # @param [PathResolver] dest_path_resolver
  # @param [Filesystem] fs
  def initialize(id:, dest_path_resolver:, fs:)
    @id = id
    @dest_path_resolver = dest_path_resolver
    @fs = fs
  end

  attr_reader :id

  # Create a link for the volume within the subset
  # defined by the dest_path_resolver.
  # This operation is idempotent.
  # @param [Volume] volume
  # @param [Pathname] src_path
  def save(volume, src_path)
    dest_path = dest_path_resolver.path(volume)
    fs.mkdir_p dest_path.parent
    fs.ln_s src_path, dest_path
  end

  # Delete a link for the volume within the
  # subset defined by the dest_path_resolver.
  # Then delete any empty parent directories
  # in the subset recursively.
  # This operation is idempotent.
  # @param [Volume] volume
  def delete(volume)
    dest_path = dest_path_resolver.path(volume)
    fs.remove(dest_path)
    fs.rm_empty_tree(dest_path.parent)
  end

  private

  attr_reader :dest_path_resolver, :fs

end