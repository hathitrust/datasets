require_relative "spec_helper"
require "dedupe_delete_log"

module Datasets
  RSpec.describe DedupeDeleteLog do
    # needs the dataset paths there
    include_context "integration" do
      it "takes an array of files as input" do
        expect(DedupeDeleteLog.new(["foo", "bar"])).not_to be_nil
      end

      it "outputs each item/profile at most once, collated by profile, sorted by id" do
        files = Array.new(2) { Tempfile.create("dedupe-deletes") }
        begin
          files[0].puts("pd\ttest.id2", "pd\ttest.id1")
          files[1].puts("pd\ttest.id3", "pd\ttest.id2", "pd_open\ttest.id1")
          files.map(&:close)

          results = DedupeDeleteLog.new(files.map(&:path)).compile_results

          expect(results).to eq(
            {"pd" => ["test.id1", "test.id2", "test.id3"],
             "pd_open" => ["test.id1"]}
          )
        ensure
          files.map { |f| File.unlink(f) }
        end
      end

      it "only outputs deletes that aren't present in the current dataset" do
        Tempfile.create("dedupe-deletes") do |f|
          f.puts("pd\ttest.still_there", "pd\ttest.not_there")
          f.close

          volume = Volume.new(namespace: "test", id: "still_there",
            access_profile: :open, right: :pd)

          writer = Datasets.config.volume_writer[:pd]
          src_path_resolver = Datasets.config.src_path_resolver[:pd]
          src_path = src_path_resolver.path(volume)
          src_path.parent.mkpath
          FileUtils.touch(src_path)
          writer.save(volume, src_path)

          results = DedupeDeleteLog.new([f.path]).compile_results
          expect(results).to eq({"pd" => ["test.not_there"]})
        end
      end
    end
  end
end
