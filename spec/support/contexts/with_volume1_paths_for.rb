# Defines various paths for the volume, and sets up automatic creation and
# deletion of those paths in tests.  Paths are exposed in various `let` statements.
#
# This context is intended to be called within the integration context.
#
# @param profile [Symbol] The rights profile for the paths, e.g. :full, :pd_world
# @param dirname [String] The name of the directory the dataset should be stored in.
#   For the full set, this is "ht_text".
# @param timestamp [Time] The timestamp of the volume's mtime.
RSpec.shared_context "with volume1 paths for" do |profile, dirname, timestamp|
  # Setup paths
  let(:root) { INTEGRATION_ROOT }
  let(:orig_src_root) { SPEC_HOME + "integration" + "src" }
  let(:src_root) { INTEGRATION_ROOT + "src" }
  let(:datasets_root) { DATASETS_ROOT }
  let(:pairtree_prefix) { Pathname.new("obj/test/pairtree_root") }

  # Create paths we actually use
  let(:"#{profile}_root") { datasets_root + dirname }
  let(:"#{profile}_reports_dir") { send(:"#{profile}_root") + "history" }
  let(:volume1_src_zip) { src_root + pairtree_prefix + "00" + "1" + "001" + "001.zip" }
  let(:volume1_dest_dir) { send(:"#{profile}_root") + pairtree_prefix + "00" + "1" + "001" }
  let(:volume1_dest_zip) { volume1_dest_dir + "001.zip" }
  let(:volume1_dest_mets) { volume1_dest_dir + "001.mets.xml" }
  let(:volume1_dest_files) { [volume1_dest_zip, volume1_dest_mets] }
  let(:volume1_zip_files) { [Pathname.new("test_volume/00000001.txt"), Pathname.new("test_volume/00000002.txt")] }

  let(:relative_volume1_dest_files) do
    volume1_dest_files
      .map { |p| p.relative_path_from(send(:"#{profile}_root")) }
  end

  before(:each) do
    system("cp -rLf #{orig_src_root} #{INTEGRATION_ROOT}")
    FileUtils.rmtree send(:"#{profile}_root")
    send(:"#{profile}_root").mkpath
    send(:"#{profile}_reports_dir").mkpath
    FileUtils.touch(volume1_src_zip, mtime: timestamp)
  end

  after(:all) do
    FileUtils.rmtree DATASETS_ROOT + dirname
  end
end
