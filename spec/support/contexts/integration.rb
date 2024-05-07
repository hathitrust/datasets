require "sequel"
require "pathname"
require "timecop"
require_relative "../../../config/hathitrust_config"
require_relative "../schema_builder"

# Performs setup and teardown for integration tests.
RSpec.shared_context "integration" do
  before(:all) do
    FileUtils.mkdir(INTEGRATION_ROOT) if !File.exist?(INTEGRATION_ROOT)
    Datasets.config = Datasets::HathiTrust::Configuration.from_yaml(CONFIG_YML)
    Datasets::SchemaBuilder.new(Datasets.config.db_connection).create!
    Timecop.freeze
  end

  around(:example) do |example|
    Datasets.config.db_connection.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end

  let(:rights_table) { Datasets.config.db_connection.from(:rights_current) }
  let(:feed_table) { Datasets.config.db_connection.from(:feed_audit) }
  let(:two_days_ago) { (Date.today - 2).to_time }
  let(:three_days_ago) { (Date.today - 3).to_time }
  let(:one_week_ago) { (Date.today - 7).to_time }

  after(:all) do
    Timecop.return
    (INTEGRATION_ROOT + "datasets").rmtree
  end
end
