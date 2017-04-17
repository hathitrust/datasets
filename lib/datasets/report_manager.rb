require "datasets/report_summary"
require "datasets/report"
require "pathname"
require "yaml"

module Datasets

  # A class that manages writing report_test.  Generally the primary
  # avenue used to write report.  Contains functionality to discover
  # the period of the most recent report and write a new one, as a sort
  # of last_run_time manager.
  class ReportManager

    TIME_FORMAT = "%Y%m%d%H%M%S"

    def initialize(parent_dir, fs)
      @parent_dir = Pathname.new parent_dir
      @fs = fs
    end

    # The period of the last completed report
    # @return [Range<Time>]
    def last_range
      last_summary.time_range
    end

    # Finds the most recent report in the parent directory, then
    # yields a new time range from the time the last report ended
    # until now.  It then creates and saves a new report with the
    # result of the block.
    # @yieldparam new_range [Range<Time>] The period from when the last
    #   report started until now.
    # @yieldreturn [Array<Array<Volume>>] The block should return the
    #   array of volumes that were saved and the array of volumes that
    #   were removed.
    # @return [Report]
    def build_next_report(&block)
      new_range = last_range.last..Time.now
      saved, deleted = yield new_range
      report = Report.new(saved, deleted, new_range, fs)
      report.save(save_path(new_range))
      report
    end

    private

    # Save according to the range as dir/YYYYMMDDHHMMSS-YYYMMDDHHMMSS/
    def save_path(range)
      parent_dir + "#{range.first.strftime(TIME_FORMAT)}-#{range.last.strftime(TIME_FORMAT)}"
    end

    def last_summary
      @last_summary ||= find_last_summary
    end

    # Find the alpha-numerically last directory that contains
    # a saved report, then open and return the summary.
    # @return [ReportSummary]
    def find_last_summary
      path = fs.children(parent_dir)
        .map{|dir| dir + "summary.yml" }
        .select {|path| fs.exists?(path) }
        .sort
        .last
      hash = YAML.load(fs.read(path))
      ReportSummary.new(hash["saved"], hash["deleted"], hash["start_time"]..hash["end_time"], fs)
    end

    attr_reader :parent_dir, :fs
  end

end