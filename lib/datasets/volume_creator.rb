require "datasets/volume_writer"

# Writes and deletes volumes within the superset.
class VolumeCreator < VolumeWriter

  # @param [PathResolver] dest_path_resolver
  # @param [ZipWriter] writer
  # @param [Filesystem] fs
  def initialize(dest_path_resolver:, writer:, fs:)
    @dest_path_resolver = dest_path_resolver
    @writer = writer
    @fs = fs
  end

  def save(volume, src_path)
    dest_path = dest_path_resolver.path(volume)
    fs.mkdir_p(dest_path)
    fs.ln_s mets_path(volume, src_path), mets_path(volume, dest_path)
    write_zip(src_path, dest_path, volume)
  end

  def delete(volume)
    dest_path = dest_path_resolver.path(volume)
    fs.remove(dest_path)
    fs.rm_empty_tree(dest_path.parent)
  end

  # Path of the zip for the volume at path
  # @param [Volume] volume
  # @param [Pathname] path
  # @return [Pathname]
  def zip_path(volume, path)
    path + "#{volume.id}.zip"
  end

  # Path of the mets for the volume at path
  # @param [Volume] volume
  # @param [Pathname] path
  # @return [Pathname]
  def mets_path(volume, path)
    path + "#{volume.id}.mets"
  end

  private

  attr_reader :dest_path_resolver, :writer, :fs

  def write_zip(src_path, dest_path, volume)
    src_zip = zip_path(volume, src_path)
    dest_zip = zip_path(volume, dest_path)
    if should_write_zip?(src_zip, dest_zip)
      writer.write(src_zip, dest_zip)
    end
  end

  def should_write_zip?(src_path, dest_path)
    !fs.exists?(dest_path) || fs.creation_time(src_path) > fs.creation_time(dest_path)
  end

end