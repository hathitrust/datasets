module Datasets

  # Represents a report of work done.  Contains methods
  # to write and read a report to and from the filesystem.
  class ReportSummary

    attr_reader :num_saved, :num_deleted, :time_range

    # Create a new report summary
    # @param num_saved [Fixnum]
    # @param num_deleted [Fixnum]
    # @param time_range [Range<Time>] The time range the volumes were added/deleted.
    # @param fs [Filesystem]
    def initialize(num_saved, num_deleted, time_range, fs)
      @num_saved = num_saved
      @num_deleted = num_deleted
      @time_range = time_range
      @fs = fs
    end

    def to_h
      {
        start_time: started,
        end_time: ended,
        saved: num_saved,
        deleted: num_deleted
      }
    end

    def started
      time_range.first
    end

    def ended
      time_range.last
    end

    private
    attr_reader :fs

  end

end