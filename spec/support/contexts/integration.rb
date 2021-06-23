require "sequel"
require "pathname"
require "timecop"
require_relative "../schema_builder"

# Performs setup and teardown for integration tests.
RSpec.shared_context "integration" do
  SPEC_HOME ||= Pathname.new(__FILE__).expand_path.dirname.parent.parent
  INTEGRATION_ROOT ||= Pathname.new("/tmp/integration")
  DB_PATH ||= INTEGRATION_ROOT + "test.db"
  CONFIG_YML ||= SPEC_HOME + "support" + "config" + "integration.yml"

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

  after(:all) do
    Timecop.return
    (INTEGRATION_ROOT + "datasets").rmtree
    DB_PATH.rmtree
  end

end
