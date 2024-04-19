require_relative "spec_helper"
require "dedupe_delete_log"

module Datasets
  RSpec.describe DedupeDeleteLog do
    # needs the dataset paths there
    include_context "integration" do
      let(:profile) { :pd }

      it "takes a profile and an array of files as input" do
        expect(DedupeDeleteLog.new(profile: profile, files: ["foo", "bar"])).not_to be_nil
      end

      it "outputs each item at most once" do
        files = Array.new(2) { Tempfile.create("dedupe-deletes") }
        begin
          files[0].puts("test.id1", "test.id2")
          files[1].puts("test.id3", "test.id2")
          files.map(&:close)

          DedupeDeleteLog.new(profile: profile, files: files.map(&:path)).compile_results do |results|
            expect(results).to contain_exactly("test.id1", "test.id2", "test.id3")
          end
        ensure
          files.map { |f| File.unlink(f) }
        end
      end

      it "only outputs deletes that aren't present in the current dataset" do
        Tempfile.create("dedupe-deletes") do |f|
          f.puts("test.still_there", "test.not_there")
          f.close

          volume = Volume.new(namespace: "test", id: "still_there", access_profile: :open, right: :pd)
          writer = Datasets.config.volume_writer[profile]
          src_path_resolver = Datasets.config.src_path_resolver[profile]
          src_path = src_path_resolver.path(volume)
          src_path.parent.mkpath
          FileUtils.touch(src_path)
          writer.save(volume, src_path)

          DedupeDeleteLog.new(profile: profile, files: [f.path]).compile_results do |results|
            expect(results).to contain_exactly("test.not_there")
          end
        end
      end
    end
  end
end
