require "datasets/repository/rights_feed_volume_repo"

module Datasets
  RSpec.describe Repository::RightsFeedVolumeRepo do
    let(:start_time) { Time.at(0) }
    let(:end_time) { Time.now }
    let(:one_day) { 86400 }
    let(:two_minutes) { 120 }
    let(:yesterday) { Time.now - one_day }
    let(:tomorrow) { Time.now + one_day }

    before(:all) do
      @connection = Sequel.connect(adapter: "mysql2",
        database: "ht",
        host: "mariadb-test",
        user: "datasets",
        password: "datasets")
      @schema_builder = SchemaBuilder.new(@connection)
      @schema_builder.create!
    end

    around(:example) do |example|
      @connection.transaction(rollback: :always, auto_savepoint: true) { example.run }
    end

    let(:feed_table) { @connection.from(:feed_audit) }
    let(:rights_table) { @connection.from(:rights_current) }
    let(:repo) { described_class.new(@connection) }

    let(:vol_feed_1) do
      {
        namespace: "mdp", id: "123098120312",
        zip_size: 3013480, zip_date: Time.new(2001, 3, 27),
        mets_size: 3232, mets_date: Time.new(2000, 9, 29),
        lastchecked: Time.new(2017, 1, 1), md5check_ok: true
      }
    end
    let(:vol_rights_1) do
      {
        namespace: vol_feed_1[:namespace], id: vol_feed_1[:id],
        attr: 1, reason: 1, source: 1, access_profile: 1,
        user: "someuser", time: Time.new(2001, 3, 28)
      }
    end
    let(:vol_feed_2) do
      {
        namespace: "inu", id: "300000312",
        zip_size: 10398103, zip_date: Time.new(2011, 2, 22),
        mets_size: 1111, mets_date: Time.new(2001, 1, 15),
        lastchecked: Time.new(2016, 5, 15), md5check_ok: nil
      }
    end
    let(:vol_rights_2) do
      {
        namespace: vol_feed_2[:namespace], id: vol_feed_2[:id],
        attr: 1, reason: 1, source: 1, access_profile: 1,
        user: "someuser", time: Time.new(2001, 3, 28)
      }
    end
    let(:vol_feed_3) do
      {
        namespace: "mdp", id: "asldfasdfasdf",
        zip_size: 99999, zip_date: Time.new(2005, 1, 14),
        mets_size: 3232, mets_date: Time.new(2000, 2, 29),
        lastchecked: Time.new(2016, 2, 23), md5check_ok: true
      }
    end
    let(:vol_rights_3) do
      {
        namespace: vol_feed_3[:namespace], id: vol_feed_3[:id],
        attr: 1, reason: 1, source: 1, access_profile: 1,
        user: "someuser", time: Time.new(2017, 1, 1)
      }
    end

    def volume_from(hash)
      Volume.new(
        namespace: hash[:namespace],
        id: hash[:id],
        access_profile: @schema_builder.access_profile(hash[:access_profile])[:name].to_sym,
        right: @schema_builder.attribute(hash[:attr])[:name].to_sym
      )
    end

    it "returns Volume objects" do
      feed_table.insert(vol_feed_1)
      rights_table.insert(vol_rights_1)
      volumes = repo.changed_between(Time.at(0), vol_rights_1[:time] + one_day)
      expect(volumes.first).to be_an_instance_of Volume
    end

    it "returns tuples with a zip_date or rights timestamp in the range" do
      # old zip and rights time
      feed_table.insert(vol_feed_1.merge(zip_date: Time.new(1997, 12, 25)))
      rights_table.insert(vol_rights_1.merge(time: Time.new(1997, 12, 25)))
      # zip date in range, old rights time
      feed_table.insert(vol_feed_2.merge(zip_date: Time.new(2002, 10, 31)))
      rights_table.insert(vol_rights_2.merge(time: Time.new(1998, 0o1, 0o1)))
      # zip date too new, rights time in range
      feed_table.insert(vol_feed_3.merge(zip_date: Time.new(2017, 1, 1)))
      rights_table.insert(vol_rights_3.merge(time: Time.new(2002, 10, 31)))

      tuples = repo.changed_between(Time.new(2001, 1, 1), Time.new(2016, 1, 1))
      expect(tuples).to contain_exactly(volume_from(vol_rights_2), volume_from(vol_rights_3))
    end

    it "does not return volumes with md5check_ok: false" do
      feed_table.insert vol_feed_1.merge(md5check_ok: false, zip_date: Time.now)
      rights_table.insert vol_rights_1
      expect(repo.changed_between(yesterday, tomorrow)).to be_empty
    end

    it "does return volumes with md5check_ok: true or null" do
      feed_table.insert vol_feed_1.merge(md5check_ok: true, zip_date: Time.now)
      rights_table.insert vol_rights_1
      feed_table.insert vol_feed_2.merge(md5check_ok: nil, zip_date: Time.now)
      rights_table.insert vol_rights_2
      expect(repo.changed_between(yesterday, tomorrow))
        .to contain_exactly(volume_from(vol_rights_1), volume_from(vol_rights_2))
    end

    it "returns an empty set when nothing to find" do
      feed_table.insert vol_feed_1
      expect(repo.changed_between(vol_feed_1[:zip_date] + one_day, vol_feed_1[:zip_date] + two_minutes))
        .to be_empty
    end

    it "does not return items in feed_audit but not rights_current" do
      feed_table.insert vol_feed_1
      expect(repo.changed_between(Time.at(0), Time.now)).to be_empty
    end

    it "does not return items in feed_audit but not rights_current" do
      feed_table.insert vol_feed_1
      expect(repo.changed_between(Time.at(0), Time.now)).to be_empty
    end
  end
end
