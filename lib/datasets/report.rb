require "datasets/report_summary"
require "yaml"

module Datasets

  # Represents a report of work done.  Contains methods
  # to write and read a report to and from the filesystem.
  class Report

    attr_reader :saved_volumes, :deleted_volumes, :time_range

    # Create a new report
    # @param saved_volumes [Array<Volume>] The volumes that were added.
    # @param deleted_volumes [Array<Volume>] The volumes that were deleted.
    # @param time_range [Range<Time>] The time range the volumes were added/deleted.
    # @param fs [Filesystem]
    def initialize(saved_volumes, deleted_volumes, time_range, fs)
      @saved_volumes = saved_volumes
      @deleted_volumes = deleted_volumes
      @time_range = time_range
      @fs = fs
    end

    # Save the report at the given report directory.
    # @param report_dir [Pathname] Path to save the report.  Note that this
    #   is _not_ the parent directory.  Created if it does not exist.
    def save(report_dir)
      fs.mkdir_p report_dir
      fs.write(report_dir + "saved.txt", volumes_to_s(saved_volumes))
      fs.write(report_dir + "deleted.txt", volumes_to_s(deleted_volumes))
      fs.write(report_dir + "summary.yml", summary.to_h.to_yaml)
    end

    def summary
      ReportSummary.new(saved_volumes.size, deleted_volumes.size, time_range, fs)
    end

    def started
      time_range.first
    end

    def ended
      time_range.last
    end

    private

    def volumes_to_s(volumes)
      volumes.map{|volume| volume_to_s(volume) }
        .join("\n")
    end

    def volume_to_s(volume)
      "#{volume.namespace}.#{volume.id}"
    end

    attr_reader :fs

  end

end