RSpec.shared_context "with mocked resque logger" do
  before(:each) do
    @orig_logger = Resque.logger
    Resque.logger = double(:logger,
                           info: nil,
                           debug: nil)
  end

  after(:each) do
    Resque.logger = @orig_logger
  end
end
