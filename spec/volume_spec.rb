# frozen_string_literal: true

require_relative "./spec_helper"
require "datasets/volume"

module Datasets
  RSpec.describe Volume do
    shared_examples "coerces parameters" do
      let(:volume) { described_class.new(**volume_params) }
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
        {namespace: "mdp", id: "12356",
         access_profile: "open", right: "pd"}
      end
      include_examples "coerces parameters"
    end

    context "given symbol parameters" do
      let(:volume_params) do
        {namespace: :mdp, id: :"8675309",
         access_profile: :closed, right: :nobody}
      end
      include_examples "coerces parameters"
    end

    context "given common volume" do
      let(:volume_params) do
        {namespace: "mdp", id: "12356",
         access_profile: :open, right: :pd}
      end

      let(:other_volume_params) do
        {namespace: "test", id: "1234",
         access_profile: :open, right: :pd}
      end

      let(:volume) { described_class.new(**volume_params) }
      let(:same_volume) { described_class.new(**volume_params) }
      let(:other_volume) { described_class.new(**other_volume_params) }

      describe "#to_h" do
        it "returns a hash with stringified keys and values" do
          expect(volume.to_h).to eql({
            "namespace" => "mdp", "id" => "12356",
            "access_profile" => "open", "right" => "pd"
          })
        end
      end

      describe "#to_s" do
        it "returns a string with the volume ID and the rights" do
          expect(volume.to_s).to eql("mdp.12356 (pd open)")
        end
      end

      describe "#eql?" do
        it "returns true for two volumes constructed from the same params" do
          expect(volume.eql?(same_volume)).to be true
        end

        it "returns false for two volumes constructed from different params" do
          expect(volume.eql?(other_volume)).to be false
        end
      end

      describe "#hash" do
        it "returns the same value for two volumes constructed from the same params" do
          expect(volume.hash).to eql(same_volume.hash)
        end

        it "returns a different value for two volumes constructed from different params" do
          expect(volume.hash).not_to eql(other_volume.hash)
        end
      end
    end
  end
end
