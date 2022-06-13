RSpec.shared_context "with mocked sidekiq logger" do
  before(:each) do
    @orig_logger = Sidekiq.logger
    Sidekiq.logger = double(:logger,
      info: nil,
      debug: nil)
  end

  after(:each) do
    Sidekiq.logger = @orig_logger
  end
end
