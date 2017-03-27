require "datasets/repository/rights_feed_volume_repo"

RSpec.describe Repository::RightsFeedVolumeRepo do
  let(:rights_volumes) { Set.new([double(:v1), double(:v2), double(:v3) ]) }
  let(:feed_tuples) { Set.new([double(:t1), double(:t2), double(:t3)]) }
  let(:feed_volumes) { Set.new([double(:v3), double(:v4), double(:v5)]) }
  let(:rights_backend) { double(:rights) }
  let(:feed_backend) { double(:feed) }
  let(:start_time) { Time.at(0) }
  let(:end_time) { Time.now }
  let(:repo) do
    described_class.new(
      rights_backend: rights_backend,
      feed_backend: feed_backend
    )
  end



  it "returns the changed rights and feed volumes" do
    allow(feed_backend).to receive(:changed_between).with(start_time, end_time)
      .and_return(feed_tuples)
    allow(rights_backend).to receive(:in).with(feed_tuples).and_return(feed_volumes)
    allow(rights_backend).to receive(:changed_between).with(start_time, end_time)
      .and_return(rights_volumes)
    expect(repo.changed_between(start_time, end_time)).to eql(feed_volumes + rights_volumes)
  end

end