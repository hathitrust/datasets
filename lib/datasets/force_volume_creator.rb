require "datasets/volume_creator"
require "pairtree"

# Writes and deletes volumes within the superset.
module Datasets
  class ForceVolumeCreator < VolumeCreator
    def should_write_zip?(src_path, dest_path)
      true
    end
  end
end
