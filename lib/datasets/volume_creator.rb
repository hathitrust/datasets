require "datasets/volume_writer"
require "pairtree"

# Writes and deletes volumes within the superset.
module Datasets
  class VolumeCreator < VolumeWriter
    # @param [PathResolver] dest_path_resolver
    # @param [ZipWriter] writer
    # @param [Filesystem] fs
    def initialize(id:, dest_path_resolver:, writer:, fs:)
      @id = id
      @dest_path_resolver = dest_path_resolver
      @writer = writer
      @fs = fs
    end

    attr_reader :id

    def save(volume, src_path)
      dest_path = dest_path_resolver.path(volume)
      fs.mkdir_p(dest_path)
      fs.ln_s mets_path(volume, src_path), mets_path(volume, dest_path)
      write_zip(src_path, dest_path, volume)
    end

    def delete(volume)
      dest_path = dest_path_resolver.path(volume)
      removed = fs.remove(dest_path)
      log(volume, removed ? "removed" : "not present")
      fs.rm_empty_tree(dest_path.parent)
    end

    # Path of the zip for the volume at path
    # @param [Volume] volume
    # @param [Pathname] path
    # @return [Pathname]
    def zip_path(volume, path)
      path + "#{pt_id(volume)}.zip"
    end

    # Path of the mets for the volume at path
    # @param [Volume] volume
    # @param [Pathname] path
    # @return [Pathname]
    def mets_path(volume, path)
      path + "#{pt_id(volume)}.mets.xml"
    end

    private

    attr_reader :dest_path_resolver, :writer, :fs

    def write_zip(src_path, dest_path, volume)
      src_zip = zip_path(volume, src_path)
      dest_zip = zip_path(volume, dest_path)
      if should_write_zip?(src_zip, dest_zip)
        writer.write(src_zip, dest_zip)
        log(volume, "updated")
      else
        log(volume, "up to date")
      end
    end

    def should_write_zip?(src_path, dest_path)
      !fs.exists?(dest_path) || fs.modify_time(src_path) > fs.modify_time(dest_path)
    end

    def pt_id(volume)
      Pairtree::Identifier.encode(volume.id)
    end
  end
end
