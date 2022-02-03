$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib/datasets"))

require 'simplecov'
require "active_support/isolated_execution_state"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/hash/slice"
SimpleCov.start

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

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
    config.default_formatter = 'doc'
  end

end

def fixtures_dir
  Pathname.new(__FILE__).dirname + "fixtures"
end
