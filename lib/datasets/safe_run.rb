require "datasets/report_manager"
require "datasets/scheduler"
require "datasets/filesystem"
require "resque"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # Nothing will be enqueued if the queue for this rights profile contains
  # pending jobs.
  class SafeRun

    # @param profile [Symbol]
    # @param report_dir [Pathname] parent directory of the reports; must exist.
    #   If not specified, will be discovered from the configuration.
    def initialize(profile, report_dir = nil, filesystem = Filesystem.new)
      @filesystem = filesystem
      @profile = profile
      @report_dir = report_dir || Datasets.config.report_dir[profile]
    end

    def execute
      if queue_empty?
        queue_and_report
      end
    end


    private
    attr_reader :profile, :report_dir, :filesystem

    # Override this in subclasses.
    def queue_and_report
      raise RuntimeError, "Not implemented."
    end

    def report_manager
       ReportManager.new(Datasets.config.report_dir[profile], filesystem)
    end

    def scheduler_for(time_range)
      Scheduler.new(
        volume_repo: Datasets.config.volume_repo[profile],
        src_path_resolver: Datasets.config.src_path_resolver[profile],
        volume_writer: Datasets.config.volume_writer[profile],
        filter: Datasets.config.filter[profile],
        time_range: time_range,
        queue: profile.to_s
      )
    end

    def queue_jobs(scheduler)
      [scheduler.add, scheduler.delete]
    end

    def queue_empty?
      Resque.size(profile.to_s) == 0
    end


  end
end
