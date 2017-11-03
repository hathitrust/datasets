class TimeRangeRetriever
  def initialize(repository:, time_range:)
    @time_range = time_range
    @repository = repository
  end

  def retrieve
    repository.changed_between(time_range.first, time_range.last)
  end

  private

  attr_reader :repository, :time_range
end
