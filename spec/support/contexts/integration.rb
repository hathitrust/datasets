require "sequel"
require "pathname"
require "timecop"
require_relative "../feed_schema_builder"
require_relative "../rights_schema_builder"

# Performs setup and teardown for integration tests.
RSpec.shared_context "integration" do
  INTEGRATION_ROOT ||= Pathname.new(__FILE__).expand_path.dirname.parent.parent + "integration"
  RIGHTS_DB_PATH ||= INTEGRATION_ROOT + "rights.db"
  FEED_DB_PATH ||= INTEGRATION_ROOT + "feed.db"
  CONFIG_YML ||= INTEGRATION_ROOT.parent + "support" + "config" + "integration.yml"

  before(:all) do
    Datasets.config = Datasets::HathiTrust::Configuration.from_yaml(CONFIG_YML)
    Datasets::RightsSchemaBuilder.new(Datasets.config.rights_db_connection).create!
    Datasets::FeedSchemaBuilder.new(Datasets.config.feed_db_connection).create!
    Timecop.freeze
  end

  around(:example) do |example|
    Datasets.config.rights_db_connection.transaction(rollback: :always, auto_savepoint: true) do
      Datasets.config.feed_db_connection.transaction(rollback: :always, auto_savepoint: true) do
        example.run
      end
    end
  end

  let(:rights_table) { Datasets.config.rights_db_connection.from(:rights_current) }
  let(:feed_table) { Datasets.config.feed_db_connection.from(:feed_audit) }

  after(:all) do
    Timecop.return
    (INTEGRATION_ROOT + "datasets").rmtree
    FEED_DB_PATH.rmtree
    RIGHTS_DB_PATH.rmtree
  end

end