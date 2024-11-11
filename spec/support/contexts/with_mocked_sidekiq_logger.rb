RSpec.shared_context "with mocked sidekiq logger" do
  before(:each) do
    @orig_logger = Sidekiq.logger
    Sidekiq.configure_embed do |config|
      config.logger = double(:logger,
        info: nil,
        debug: nil)
    end
  end

  after(:each) do
    Sidekiq.configure_embed do |config|
      config.logger = @orig_logger
    end
  end
end
