require "datasets/safe_run"

module Datasets

  # Represents a "safe run" of a scheduler for the specified rights profile.
  # that runs under a ReportManager. Also automates discovery of previous
  # reports and generation of a new report (if an action is taken).
  class ManagedSafeRun < SafeRun

    private
    def queue_and_report
      report_manager.build_next_report do |time_range|
        queue_jobs(scheduler_for(time_range))
      end
    end
  end
end
