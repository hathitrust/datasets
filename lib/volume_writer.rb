require "filesystem"
require "volume"
require "zip_writer"

# Writes and deletes volumes to the filesystem
# This is responsible for making all of the
# *decisions* around whether or not to write or
# delete files.
class VolumeWriter

  # @param [IPathResolver] dest_path_resolver
  # @param [ZipWriter] writer
  # @param [Filesystem] fs
  def initialize(dest_path_resolver:, writer:, fs:)
    @dest_path_resolver = dest_path_resolver
    @writer = writer
    @fs = fs
  end


  # Save a volume to the filesystem.  This is
  # an idempotent operation.
  # @param [Volume] volume
  # @param [String] src_path Path to the volume's source directory.
  def save(volume, src_path)
    dest_path = dest_path_resolver.path(volume)
    unless fs.exists?(zip_file(dest_path))
      fs.mkdir_p(dest_path)
      writer.write(src_path, zip_file(dest_path)) # unclear if we should be passing zips or dirs here
    end
    unless fs.exists?(mets_file(dest_path))
      fs.cp(mets_file(src_path), mets_file(dest_path))
    end
  end

  # Delete a volume from the filesystem.  This is
  # an idempotent operation.
  # @param [Volume] volume
  def delete(volume)
    dest_path = dest_path_resolver.path(volume)
    if fs.exists?(dest_path)
      fs.remove_entry_secure(dest_path)
      # then walk up the pairtree deleting any empty dirs
    end
  end

  def mets_file(path)
    path + 'metz'
  end

  def zip_file(path)
    path + 'foo.zip'
  end

  private

  attr_reader :dest_path_resolver, :writer, :fs

end