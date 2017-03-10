require "set"
require "sequel"

module Repository
  class FeedBackend

    def initialize(connection)
      @connection = connection
      @table_name = :feed_audit
    end

    # Retrieve all unique volumes that have had a change in
    # their rights within the given time period.
    # The list is unordered.
    # @param [Time] start_time
    # @param [Time] end_time
    # @return Set<Hash> Each hash contains exactly the keys *:namespace*
    #   and *:id*.
    def changed_between(start_time, end_time)
      connection[table_name]
        .where(zip_date: start_time..end_time)
        .exclude_where(zipcheck_ok: false)
        .select(:namespace, :id)
        .to_set
    end

    private

    attr_reader :connection, :table_name

  end
end
