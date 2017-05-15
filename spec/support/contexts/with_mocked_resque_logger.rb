RSpec.shared_context "with mocked resque logger" do
  before(:each) do
    Resque.logger = double(:logger,
                           info: nil,
                           debug: nil)
  end
end
