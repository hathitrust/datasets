# Defines various paths for the volume, and sets up automatic creation and
# deletion of those paths in tests.  Paths are exposed in various `let` statements.
#
# This context is intended to be called within the integration context.
#
# @param profile [Symbol] The rights profile for the paths, e.g. :full, :pd_world
# @param dirname [String] The name of the directory the dataset should be stored in.
#   For the full set, this is "ht_text".
# @param timestamp [Time] The timestamp of the volume's mtime.
RSpec.shared_context "with volume2 paths for" do |profile, dirname, timestamp|
  # Setup paths
  INTEGRATION_ROOT ||= Pathname.new(__FILE__).expand_path.dirname.parent.parent + "integration"
  DATASETS_ROOT ||= INTEGRATION_ROOT + "datasets"
  let(:root) { INTEGRATION_ROOT }
  let(:src_root) { root + "src" }
  let(:datasets_root) { DATASETS_ROOT }
  let(:pairtree_prefix) { Pathname.new("obj/test/pairtree_root") }


  # Create paths we actually use
  let(:"#{profile}_root") { datasets_root + dirname }
  let(:"#{profile}_reports_dir") { send(:"#{profile}_root") + "history" }
  let(:volume2_src_zip) { src_root + pairtree_prefix + "00" + "2" + "002" + "002.zip" }
  let(:volume2_dest_dir) { send(:"#{profile}_root") + pairtree_prefix + "00" + "2" + "002" }
  let(:volume2_dest_zip) { volume2_dest_dir + "002.zip" }
  let(:volume2_dest_mets) { volume2_dest_dir + "002.mets.xml" }
  let(:volume2_dest_files) { [volume2_dest_zip, volume2_dest_mets] }
  let(:volume2_zip_files) { [ Pathname.new("test_volume/00000001.txt"), Pathname.new("test_volume/00000002.txt")] }

  let(:relative_volume2_dest_files) do
    volume2_dest_files
      .map{|p| p.relative_path_from(send(:"#{profile}_root"))}
  end

  before(:each) do
    FileUtils.rmtree send(:"#{profile}_root")
    send(:"#{profile}_root").mkpath
    send(:"#{profile}_reports_dir").mkpath
    FileUtils.touch(volume2_src_zip, mtime: timestamp)
  end

  after(:all) do
    FileUtils.rmtree DATASETS_ROOT + dirname
  end
end