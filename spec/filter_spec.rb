require_relative './spec_helper'
require 'volume'
require 'filter'
require 'filter/full_set_filter'
require 'filter/pd_filter'
require 'filter/pd_open_filter'
require 'filter/pd_world_filter'
require 'filter/pd_world_open_filter'

def expect_match(attr, access_profile, matches)
  expected_word = matches ? 'matches' : 'does not match'
  it "#{expected_word} material with rights attribute #{attr}, access profile #{access_profile}" do
    v = Volume.new(namespace: 'test', id: '12345', right: attr, access_profile: access_profile)
    expect(described_class.new.matches?(v)).to be(matches)
  end
end

RSpec.shared_examples_for 'a filter that does not match restricted access profiles and rights attributes' do
  [:page, :"page+lowres"].each do |access_profile|
    expect_match(:pd, access_profile, false)
  end

  [:nobody, :"pd-pvt", :supp].each do |attr|
    expect_match(attr, :open, false)
  end
end

RSpec.shared_examples_for 'a filter that matches world-accessible rights attributes' do
  [:pd,
   :"ic-world",
   :"und-world",
   :"cc-by-3.0",
   :"cc-by-4.0",
   :"cc-by-nc-3.0",
   :"cc-by-nc-4.0",
   :"cc-by-nc-nd-3.0",
   :"cc-by-nc-nd-4.0",
   :"cc-by-nc-sa-3.0",
   :"cc-by-nc-sa-4.0",
   :"cc-by-nd-3.0",
   :"cc-by-nd-4.0",
   :"cc-by-sa-3.0",
   :"cc-by-sa-4.0",
   :"cc-zero"].each do |attr|
     expect_match(attr, :open, true)
   end
end

RSpec.shared_examples_for 'a filter that matches google material' do
  expect_match(:pd, :google, true)
end

RSpec.shared_examples_for 'a filter that does not match google material' do
  expect_match(:pd, :google, false)
end

RSpec.shared_examples_for 'a filter that matches pdus material' do
  expect_match(:pdus, :open, true)
end

RSpec.shared_examples_for 'a filter that does not match pdus material' do
  expect_match(:pdus, :open, false)
end

RSpec.shared_examples_for 'a filter that matches in-copyright and google material' do
  [:ic, :icus, :op].each do |attr|
    [:google, :open].each do |access_profile|
      expect_match(attr, access_profile, true)
    end
  end
end

RSpec.shared_examples_for 'a filter that does not match in-copyright material' do
  [:ic, :icus, :op].each do |attr|
    [:google, :open].each do |access_profile|
      expect_match(attr, access_profile, false)
    end
  end
end

RSpec.describe FullSetFilter do
  describe '#matches?' do
    it_behaves_like 'a filter that matches world-accessible rights attributes'
    it_behaves_like 'a filter that does not match restricted access profiles and rights attributes'
    it_behaves_like 'a filter that matches google material'
    it_behaves_like 'a filter that matches pdus material'
    it_behaves_like 'a filter that matches in-copyright and google material'
  end
end

RSpec.describe PdFilter do
  describe '#matches?' do
    it_behaves_like 'a filter that matches world-accessible rights attributes'
    it_behaves_like 'a filter that does not match restricted access profiles and rights attributes'
    it_behaves_like 'a filter that matches google material'
    it_behaves_like 'a filter that matches pdus material'
    it_behaves_like 'a filter that does not match in-copyright material'
  end
end

RSpec.describe PdWorldFilter do
  describe '#matches?' do
    it_behaves_like 'a filter that matches world-accessible rights attributes'
    it_behaves_like 'a filter that does not match restricted access profiles and rights attributes'
    it_behaves_like 'a filter that matches google material'
    it_behaves_like 'a filter that does not match pdus material'
    it_behaves_like 'a filter that does not match in-copyright material'
  end
end

RSpec.describe PdOpenFilter do
  describe '#matches?' do
    it_behaves_like 'a filter that matches world-accessible rights attributes'
    it_behaves_like 'a filter that does not match restricted access profiles and rights attributes'
    it_behaves_like 'a filter that does not match google material'
    it_behaves_like 'a filter that matches pdus material'
    it_behaves_like 'a filter that does not match in-copyright material'
  end
end

RSpec.describe PdWorldOpenFilter do
  describe '#matches?' do
    it_behaves_like 'a filter that matches world-accessible rights attributes'
    it_behaves_like 'a filter that does not match restricted access profiles and rights attributes'
    it_behaves_like 'a filter that does not match google material'
    it_behaves_like 'a filter that does not match pdus material'
    it_behaves_like 'a filter that does not match in-copyright material'
  end
end
