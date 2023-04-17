require "datasets/scheduler"
require "datasets/retriever/time_range_retriever"
require "datasets/filesystem"
require "datasets/job"
require "sidekiq/api"
require "pathname"

module Datasets
  # Represents a "safe run" of a scheduler for the specified rights profile.
  # Nothing will be enqueued if the queue for this rights profile contains
  # pending jobs.
  class SafeRun
    def execute
      raise "Queue is not empty; not queuing more (check sidekiq-web)" unless queue_empty?

      Datasets.config.profiles.each do |profile|
        queue_and_report(profile.to_sym)
      end
    end

    def report_dir(profile)
      Pathname.new(Datasets.config.report_dir[profile])
    end

    def queue_and_report(profile)
      raise "Not implemented."
    end

    def time_scheduler_for(profile, time_range)
      puts "Scheduling updates for #{profile} #{time_range}"
      Scheduler.new(
        src_path_resolver: Datasets.config.src_path_resolver[profile],
        volume_writer: Datasets.config.volume_writer[profile],
        filter: Datasets.config.filter[profile],
        retriever: TimeRangeRetriever.new(
          time_range: time_range,
          repository: Datasets.config.volume_repo[profile]
        )
      )
    end

    def queue_empty?
      Sidekiq::Queue.new.size == 0 &&
        Sidekiq::RetrySet.new.size == 0 &&
        Sidekiq::ScheduledSet.new.size == 0 &&
        Sidekiq::DeadSet.new.size == 0
    end
  end
end
