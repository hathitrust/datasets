RSpec.shared_context "with volume creator fixtures" do
  let(:log_prefix) { "profile: some_id, volume: mocked_volume" }

  let(:fs) do
    double(:fs,
           mkdir_p: nil,
           ln_s: nil,
           rm_empty_tree: nil)
  end

  let(:volume) do
    double(:volume,
           namespace: namespace,
           id: volume_id,
           to_s: "mocked_volume")
  end

  let(:dest_path) { Pathname.new("/dest/#{pt_path}/#{volume_id}") }
  let(:src_path) { Pathname.new("/src/#{pt_path}/#{volume_id}") }
  let(:src_zip) { src_path + "#{pt_volume_id}.zip" }
  let(:dest_zip) { dest_path + "#{pt_volume_id}.zip" }
  let(:src_mets) { src_path + "#{pt_volume_id}.mets.xml" }
  let(:dest_mets) { dest_path + "#{pt_volume_id}.mets.xml" }

  let(:dest_path_resolver) { double(:dpr, path: dest_path) }

  let(:writer) { double(:writer, write: nil) }
  let(:some_id) { :some_id }
  let(:volume_creator) do
    described_class.new(
      id: some_id,
      dest_path_resolver: dest_path_resolver,
      writer: writer, fs: fs
    )
  end
end
