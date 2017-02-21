require "volume"

# Interface for constructing filesystem paths from volumes.
class PathResolver

  # @param [Volume] volume
  # @return [String]
  def path(volume); end

end
