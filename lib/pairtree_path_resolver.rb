require "path_resolver"
require "volume"

class PairtreePathResolver < PathResolver

  def initialize(parent_dir)
    @parent_dir = parent_dir
  end

  def path(volume)
    # Construct a path using parent_dir, Pairtree,
    # and the volume's ns+id.
  end


  private

  attr_reader :parent_dir

end