require_relative "./spec_helper.rb"
require "datasets/volume"

module Datasets
  RSpec.describe Volume do
    shared_examples "coerces parameters" do
      let(:volume) { described_class.new(volume_params) }
      [:namespace, :id].each do |field|
        it "##{field} is a string" do
          expect(volume.public_send(field)).to eql(volume_params[field].to_s)
        end
      end
      [:access_profile, :right].each do |field|
        it "##{field} is a symbol" do
          expect(volume.public_send(field)).to eql(volume_params[field].to_sym)
        end
      end
    end

    context "given string parameters" do
      let(:volume_params) do
        { namespace: "mdp", id: "12356",
          access_profile: "open", right: "pd"}
      end
      include_examples "coerces parameters"
    end

    context "given symbol parameters" do
      let(:volume_params) do
        { namespace: :mdp, id: :"8675309",
          access_profile: :closed, right: :nobody}
      end
      include_examples "coerces parameters"
    end

    describe "#to_h" do
      let(:volume_params) do
        { namespace: "mdp", id: "8675309",
          access_profile: :closed, right: :nobody}
      end
      let(:volume) { described_class.new(volume_params) }
      it "returns a hash representing the volume" do
        expect(volume.to_h).to eql(volume_params)
      end
    end

  end
end
