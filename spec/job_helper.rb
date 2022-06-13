require "sidekiq"
require "datasets"

require 'sidekiq/testing'
Sidekiq::Testing.inline!

shared_context "with mocked job parameters" do
  let(:volume) do
    Datasets::Volume.new(namespace: 'test',
               id: 'test_id',
               access_profile: :test_profile,
               right: :test_right)
  end
  let(:src_path) { Pathname.new("some/path") }
  let(:volume_writer) { double(:volume_writer, id: :something, delete: nil) }
  let(:repo) { { something: volume_writer } } 
  before(:each) { Datasets.config = Datasets::Configuration.new({ volume_writer: repo }) }
  after(:each) { Datasets.config = Datasets::Configuration.new }
end
