# Interface for retrieving volumes from the rights database.
module Datasets
  class VolumeRepo
    # Retrieve all unique volumes that have changed
    # within the given time period. The list is unordered.
    # @param [Time] start_time
    # @param [Time] end_time
    # @return Set<Volume>
    def changed_between(start_time, end_time); end
  end
end
