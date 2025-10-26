# frozen_string_literal: true

require "json"
require "nokogiri"
require "spec_helper"
require_relative "../../lib/item_serializer_service"

RSpec.describe ItemSerializerService do
  let(:feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:item_document) { Nokogiri::XML(File.read(feed_path)).at_xpath("//item") }

  describe ".call" do
    it "returns JSON with the expected fields" do
      serialized = described_class.call(item_document, max_bytes: 10_000)

      expect(JSON.parse(serialized)).to eq(
        "id" => "1",
        "title" => "First item",
        "description" => "First item description"
      )
    end

    it "raises an error when the payload exceeds the size limit" do
      expect do
        described_class.call(item_document, max_bytes: 10)
      end.to raise_error(ItemSerializerService::SerializeItemError)
    end
  end
end
