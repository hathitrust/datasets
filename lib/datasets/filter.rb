# Filters volumes based on criteria.
class Filter

  # Filter out volumes that do not meet this filter's
  # critera.
  # @param [Array<Volume>] volumes
  # @return [Array<Volume>]
  def filter(volumes); end

  # Filter out volumes that *do* meet this filter's
  # critera.
  # @param [Array<Volume>] volumes
  # @return [Array<Volume>]
  def inverse_filter(volumes); end

  # Check if a single volume is in the set described by
  # this filter.
  # @param [Volume] volume
  # @return [Boolean]
  def in?(volume);  end
end
