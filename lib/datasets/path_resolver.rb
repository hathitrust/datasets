# Interface for constructing filesystem paths from volumes.
class PathResolver

  # @param [Volume] volume
  # @return [Pathname]
  def path(volume); end

  # Return the parent_dir this resolver was initialized with.
  # @return [Pathname]
  def parent_dir(volume); end

end
