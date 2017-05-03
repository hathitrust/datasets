require "datasets/scheduler"
require "datasets/filesystem"
require "datasets/job"
require "resque"
require "pathname"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # Nothing will be enqueued if the queue for this rights profile contains
  # pending jobs.
  class SafeRun
    def execute
      if queue_empty?
        Datasets.config.profiles.each do |profile|
          queue_and_report(profile.to_sym)
        end
      end
    end

    def report_dir(profile)
      Pathname.new(Datasets.config.report_dir[profile])
    end

    def queue_and_report(profile)
      raise RuntimeError, "Not implemented."
    end

    def scheduler_for(profile, time_range)
      Scheduler.new(
        volume_repo: Datasets.config.volume_repo[profile],
        src_path_resolver: Datasets.config.src_path_resolver[profile],
        volume_writer: Datasets.config.volume_writer[profile],
        filter: Datasets.config.filter[profile],
        time_range: time_range
      )
    end

    def queue_empty?
      Resque.size(Job.queue) == 0
    end

  end
end
