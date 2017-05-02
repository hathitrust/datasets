require "datasets/report_manager"
require "datasets/scheduler"
require "datasets/filesystem"
require "resque"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # It is not managed with a Report Manager, so you must pass the time range
  # for the updates directly.
  
  class UnmanagedSafeRun < SafeRun
    # @param profile [Symbol]
    # @param report_dir [Pathname] parent directory of the reports; must exist.
    #   If not specified, will be discovered from the configuration.
    def initialize(profile, time_range, report_dir = nil, filesystem = Filesystem.new)
      super(profile,report_dir,filesystem)
      @time_range = time_range
    end


    private
    def queue_and_report
      saved, deleted = queue_jobs(scheduler_for(time_range))
      Report.new(saved, deleted, time_range, filesystem)
        .save(report_manager.save_path(time_range))
    end

    attr_reader :time_range

  end
end
