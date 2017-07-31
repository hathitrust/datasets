# Given a timestamp, exposes the relative paths to the various report files
# from the rights profile directory's root (e.g. ht_text).
# @param time_range [Range<Time>] The time period the report covers.
RSpec.shared_context "relative report paths" do |time_range|
  let(:report_dirname) do
    time_range ||= Time.at(0)..Date.today.prev_day.to_time
    time_range.first.strftime("%Y%m%d%H%M%S") + "-" + time_range.last.strftime("%Y%m%d%H%M%S")
  end

  let(:report_dir) { Pathname.new("history") + report_dirname }
  let(:saved_report) { report_dir + "saved.txt" }
  let(:deleted_report) { report_dir + "deleted.txt" }
  let(:summary_report) { report_dir + "summary.yml" }

  let(:relative_report_files) { [saved_report, deleted_report, summary_report] }
end
