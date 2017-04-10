require_relative "../spec_helper"
require "repository/memory_repo"

module Datasets
  RSpec.describe MemoryRepo do
    let(:repo) { described_class.new }
    let(:thing) { [{a:1}, [1,2,3]]}
    it "can save and find objects by id" do
      repo.save(:some_id, thing)
      expect(repo.find(:some_id)).to eql(thing)
    end
  end

end