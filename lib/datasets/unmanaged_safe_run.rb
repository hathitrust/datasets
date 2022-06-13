require "datasets/scheduler"
require "datasets/filesystem"
require "sidekiq"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # It is not managed with a Report Manager, so you must pass the time range
  # for the updates directly.
  
  class UnmanagedSafeRun < SafeRun
    # @param report_path [Pathname]
    def initialize(time_range, fs = Filesystem.new)
      @time_range = time_range
      @fs = fs
    end

    def queue_and_report(profile)
      scheduler = time_scheduler_for(profile, time_range)
      Report.new(scheduler.add, scheduler.delete, time_range, fs)
        .save(save_path(profile))
    end

    private
    attr_reader :time_range, :fs

    TIME_FORMAT = "%Y%m%d%H%M%S"

    def save_path(profile)
      report_dir(profile) + "#{time_range.first.strftime(TIME_FORMAT)}-#{time_range.last.strftime(TIME_FORMAT)}"
    end


  end
end
