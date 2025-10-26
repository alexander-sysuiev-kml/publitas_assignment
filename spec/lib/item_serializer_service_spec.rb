# frozen_string_literal: true

require "json"
require "nokogiri"
require "spec_helper"
require_relative "../../lib/services/item_serializer_service"

RSpec.describe ItemSerializerService do
  let(:feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:item_document) { Nokogiri::XML(File.read(feed_path)).at_xpath("//item") }

  describe ".call" do
    it "returns the expected attributes as a hash" do
      serialized = described_class.call(item_document)

      expect(serialized).to eq(
        "id" => "1",
        "title" => "First item",
        "description" => "First item description"
      )
    end

    it "omits fields that are not present on the document" do
      incomplete_document = Nokogiri::XML(<<~XML).at_xpath("//item")
        <item xmlns:g="http://base.google.com/ns/1.0">
          <g:id>123</g:id>
          <description>Only description</description>
        </item>
      XML

      serialized = described_class.call(incomplete_document)

      expect(serialized["title"]).to be_nil
    end
  end
end
