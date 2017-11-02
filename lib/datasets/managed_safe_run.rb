require "datasets/safe_run"
require "datasets/report_manager"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # that runs under a ReportManager. Also automates discovery of previous
  # reports and generation of a new report (if an action is taken).
  class ManagedSafeRun < SafeRun

    def initialize(fs = Filesystem.new)
      @fs = fs
    end

    def queue_and_report(profile)
      report_manager(profile).build_next_report do |time_range|
        scheduler = time_scheduler_for(profile, time_range)
        [scheduler.add, scheduler.delete]
      end
    end

    private
    attr_reader :fs

    def report_manager(profile)
      ReportManager.new(report_dir(profile), fs)
    end

  end
end
