require "volume"

# Interface for retrieving volumes from the rights database.
class VolumeRepo
  # @param [Time] time A local time
  # @return Array<Volume>
  def changed_since(time); end
end
