require "datasets/report_manager"
require "datasets/scheduler"
require "datasets/filesystem"
require "resque"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # Nothing will be enqueued if the queue for this rights profile contains
  # pending jobs.  Also automates discovery of previous reports and generation
  # of a new report (if an action is taken).
  class SafeRun

    # @param profile [Symbol]
    # @param report_dir [Pathname] parent directory of the reports; must exist.
    #   If not specified, will be discovered from the configuration.
    def initialize(profile, report_dir = nil)
      @profile = profile
      @report_dir = report_dir || Datasets.config.report_dir[profile]
    end

    def execute
      if queue_empty?
        report_manager = Datasets::ReportManager.new(report_dir, Filesystem.new)
        report_manager.build_next_report do |time_range|
          scheduler = Scheduler.new(
            volume_repo: Datasets.config.volume_repo[profile],
            src_path_resolver: Datasets.config.src_path_resolver[profile],
            volume_writer: Datasets.config.volume_writer[profile],
            filter: Datasets.config.filter[profile],
            time_range: time_range,
            queue: profile.to_s
          )
          [scheduler.add, scheduler.delete]
        end
      end
    end

    def queue_empty?
      Resque.size(profile.to_s) == 0
    end

    private
    attr_reader :profile, :report_dir

  end
end