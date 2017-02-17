
require "link"
require "volume"
require "pairtree"

# Responsible for all decisions around building links
# from volumes, but does not have knowledge of the filesystem.
class LinkBuilder

  def initialize(volume_root_dir)
    @volume_root_dir = volume_root_dir
  end

  def link(volume)
  end

end
