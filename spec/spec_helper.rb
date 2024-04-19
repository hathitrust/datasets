$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib/datasets"))

require "simplecov"
require "simplecov-lcov"
require "sidekiq"

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])
SimpleCov.start
Sidekiq.strict_args!

Dir[File.expand_path(File.join(File.dirname(__FILE__), "support", "**", "*.rb"))].each { |f| require f }

SPEC_HOME = Pathname.new(__FILE__).expand_path.dirname
INTEGRATION_ROOT = Pathname.new("/tmp/integration")
DATASETS_ROOT = INTEGRATION_ROOT + "datasets"
CONFIG_YML = SPEC_HOME + "support" + "config" + "integration.yml"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
end

def fixtures_dir
  Pathname.new(__FILE__).dirname + "fixtures"
end
