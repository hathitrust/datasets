require "spec_helper"
require "repository/rights_volume_repo"
require "volume"

require "set"
require "sequel"
require "sqlite3"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/hash/slice"


module Datasets
  RSpec.describe Repository::RightsVolumeRepo do
    before(:all) do
      @connection = Sequel.sqlite
      @schema_builder = SchemaBuilder.new(@connection)
      @schema_builder.create!
    end

    around(:example) do |example|
      @connection.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end

    let(:table) { @connection.from(:rights_current) }
    let(:repo) { described_class.new(@connection) }
    let(:tuple_1) do
      {
        namespace: "mdp", id: "120398120938",
        attr: 1, reason: 1, source: 1, access_profile: 1,
        user: "someuser", time: Time.new(1997, 12, 25)
      }
    end
    let(:tuple_2) do
      {
        namespace: "mdp", id: "22222222",
        attr: 1, reason: 1, source: 1, access_profile: 1,
        user: "someuser", time: Time.new(2002, 10, 31)
      }
    end
    let(:tuple_3) do
      {
        namespace: "mdp", id: "3333333333",
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

    describe "#rights_changed_between" do
      it "returns Volume objects" do
        table.insert(tuple_1)
        volumes = repo.changed_between(Time.at(0), tuple_1[:time] + 1.day)
        expect(volumes.first).to be_an_instance_of Volume
      end

      it "returns only those volumes in the range" do
        table.insert(tuple_1.merge(time: Time.new(1997, 12, 25)))
        table.insert(tuple_2.merge(time: Time.new(2002, 10, 31)))
        table.insert(tuple_3.merge(time: Time.new(2017, 1, 1)))
        volumes = repo.changed_between(Time.new(2001, 1, 1), Time.new(2016, 1, 1))
        expect(volumes).to contain_exactly(volume_from(tuple_2))
      end

      it "returns empty set when there are no volumes to find" do
        table.insert(tuple_1.merge(time: Time.new(2017)))
        expect(repo.changed_between(Time.new(2015), Time.new(2016))).to be_empty
      end
    end


  end
end
