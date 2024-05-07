require_relative "spec_helper"
require "notify"

module Datasets
  RSpec.describe Notify do
    # needs the dataset paths there
    include_context "integration" do
      it "outputs an email with deletes" do
        Tempfile.create("dedupe-deletes") do |f|
          f.puts("pd\ttest.id1", "pd\ttest.id2")
          f.close

          notifier = Notify.new([f.path], dry_run: true, smtp_host: "default.invalid")
          expect { notifier.notify }.to output(/Delete notification.*test\.id1.*test\.id2/m).to_stdout
        end
      end
    end
  end
end
