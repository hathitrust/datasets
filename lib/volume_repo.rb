require "volume"

# Interface for retrieving volumes from the rights database.
class VolumeRepo
  # Retrieve all unique volumes that have change since
  # the given time.  The list is unordered.
  # @param [Time] time A local time
  # @return Set<Volume>
  def changed_since(time); end
end
