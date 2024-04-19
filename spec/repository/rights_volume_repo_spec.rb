require "spec_helper"
require "repository/rights_volume_repo"
require "volume"
require "set"
require "sequel"

module Datasets
  RSpec.describe Repository::RightsVolumeRepo do
    let(:one_day) { 86400 }

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
    let(:tuple_miun) do
      {
        namespace: "miun", id: "agd9059.0001.001",
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
        volumes = repo.changed_between(Time.at(0), tuple_1[:time] + one_day)
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

    describe "#volumes" do
      before(:each) do
        [tuple_1, tuple_2, tuple_3, tuple_miun].each do |tuple|
          table.insert(tuple)
        end
      end

      it "returns Volume objects" do
        volumes = repo.volumes(["mdp.120398120938"])
        expect(volumes.first).to be_an_instance_of Volume
      end

      it "returns the correct volume" do
        volumes = repo.volumes(["mdp.120398120938"])
        expect(volumes).to contain_exactly(volume_from(tuple_1))
      end

      it "returns the correct volume" do
        volumes = repo.volumes(["mdp.22222222"])
        expect(volumes).to contain_exactly(volume_from(tuple_2))
      end

      it "returns a volume with more than one '.' in the id" do
        volumes = repo.volumes(["miun.agd9059.0001.001"])
        expect(volumes).to contain_exactly(volume_from(tuple_miun))
      end

      it "returns only those volumes that were requested" do
        volumes = repo.volumes(["mdp.120398120938", "mdp.22222222"])
        expect(volumes).to contain_exactly(volume_from(tuple_1), volume_from(tuple_2))
      end
    end
  end
end
