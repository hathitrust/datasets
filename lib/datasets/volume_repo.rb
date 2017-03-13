# Interface for retrieving volumes from the rights database.
class VolumeRepo
  # Retrieve all unique volumes that have had a change in
  # their rights within the given time period.
  # The list is unordered.
  # @param [Time] start_time
  # @param [Time] end_time
  # @return Set<Volume>
  def rights_changed_between(start_time, end_time); end

  # Retrieve all unique volumes that have had a content
  # change within the given time period.
  # The list is unordered.
  # @param [Time] start_time
  # @param [Time] end_time
  # @return Set<Volume>
  def zip_changed_between(start_time, end_time); end
end
