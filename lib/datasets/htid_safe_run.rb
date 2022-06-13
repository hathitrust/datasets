require "datasets/scheduler"
require "datasets/safe_run"
require "datasets/filesystem"
require "sidekiq"

module Datasets
  # Represents a "safe run" of a scheduler for the specified rights profile.
  # It takes a list of volumes to update directly; the time range is only used
  # to tag the report.

  class HTIDSafeRun < SafeRun
    # @param report_path [Pathname]
    def initialize(htids = [], fs = Filesystem.new)
      @fs = fs
      @htids = htids
      @time = Time.now
    end

    def queue_and_report(profile)
      scheduler = htid_scheduler(profile)
      Report.new(scheduler.add, scheduler.delete, time..time, fs)
        .save(save_path(profile))
    end

    private

    attr_reader :time_range, :fs, :time, :htids

    TIME_FORMAT = "%Y%m%d%H%M%S"

    def htid_scheduler(profile)
      Scheduler.new(
        src_path_resolver: Datasets.config.src_path_resolver[profile],
        volume_writer: Datasets.config.volume_writer[profile],
        filter: Datasets.config.filter[profile],
        retriever: HTIDRetriever.new(
          htids: htids,
          repository: Datasets.config.volume_repo[profile]
        )
      )
    end

    def save_path(profile)
      report_dir(profile) + "manual_update_#{time.strftime(TIME_FORMAT)}"
    end
  end
end
