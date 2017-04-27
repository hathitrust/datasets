require "datasets"

module Datasets
  class SchedulerJob < Job
    @queue = :all

    def initialize(profile, report_dir = nil)
      @profile = profile
    end

    def perform
      report_manager = Datasets::ReportManager.new(Datasets.config.report_dir[profile], Filesystem.new)
      report_manager.build_next_report do |time_range|
        scheduler = Scheduler.new(
          volume_repo: Datasets.config.volume_repo[profile],
          src_path_resolver: Datasets.config.src_path_resolver[profile],
          volume_writer: Datasets.config.volume_writer[profile],
          filter: Datasets.config.filter[profile],
          time_range: time_range
        )
        [scheduler.add, scheduler.delete]
      end
    end

    def serialize
      [profile.to_s]
    end

    def self.deserialize(profile)
      new(profile.to_sym)
    end

    private
    attr_accessor :profile
  end
end
