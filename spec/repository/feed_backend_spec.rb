require "spec_helper"
require "repository/feed_backend"
require "volume"

require "set"
require "sequel"
require "sqlite3"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/hash/slice"


RSpec.describe Repository::FeedBackend do
  before(:all) do
    @connection = Sequel.sqlite
    FeedSchemaBuilder.new(@connection).create!
  end

  around(:example) do |example|
    @connection.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  let(:table) { @connection.from(:feed_audit) }
  let(:repo) { described_class.new(@connection) }

  let(:t1) do
    {
      namespace: "mdp", id: "123098120312",
      zip_size: 3013480, zip_date: Time.new(2001, 3, 27),
      mets_size: 3232, mets_date: Time.new(2000, 9, 29),
      lastchecked: Time.new(2017, 1, 1), zipcheck_ok: true
    }
  end
  let(:t2) do
    {
      namespace: "inu", id: "300000312",
      zip_size: 10398103, zip_date: Time.new(2011, 2, 22),
      mets_size: 1111, mets_date: Time.new(2001, 1, 15),
      lastchecked: Time.new(2016, 5, 15), zipcheck_ok: nil
    }
  end
  let(:t3) do
    {
      namespace: "mdp", id: "asldfasdfasdf",
      zip_size: 99999, zip_date: Time.new(2005, 1, 14),
      mets_size: 3232, mets_date: Time.new(2000, 2, 29),
      lastchecked: Time.new(2016, 2, 23), zipcheck_ok: true
    }
  end

  describe "#zip_changed_between" do
    it "returns :namespace :id pairs as hashes" do
      table.insert t1
      tuples = repo.changed_between(t1[:zip_date] - 1.day, t1[:zip_date] + 1.day)
      expect(tuples).to contain_exactly(t1.slice(:namespace, :id))
    end

    it "returns an empty set when nothing to find" do
      table.insert t1
      expect(repo.changed_between(t1[:zip_date] + 1.day, t1[:zip_date] + 2.minutes))
        .to eql Set.new
    end

    it "returns tuples with a zip_date in the range" do
      table.insert(t1.merge(zip_date: Time.new(1997, 12, 25)))
      table.insert(t2.merge(zip_date: Time.new(2002, 10, 31)))
      table.insert(t3.merge(zip_date: Time.new(2017, 1, 1)))
      tuples = repo.changed_between(Time.new(2001, 1, 1), Time.new(2016, 1, 1))
      expect(tuples).to contain_exactly(t2.slice(:namespace, :id))
    end

    it "does not return volumes with zipcheck_ok: false" do
      table.insert t1.merge(zipcheck_ok: false, zip_date: Time.now)
      expect(repo.changed_between(1.day.ago, 1.day.from_now)).to eql Set.new
    end

    it "does return volumes with zipcheck_ok: true or null" do
      table.insert t1.merge(zipcheck_ok: true, zip_date: Time.now)
      table.insert t2.merge(zipcheck_ok: nil, zip_date: Time.now)
      expect(repo.changed_between( 1.day.ago, 1.day.from_now))
        .to contain_exactly(t1.slice(:namespace, :id), t2.slice(:namespace, :id))
    end

  end

end
