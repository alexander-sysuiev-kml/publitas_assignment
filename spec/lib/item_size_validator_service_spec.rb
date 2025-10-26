# frozen_string_literal: true

require "json"
require "spec_helper"
require_relative "../../lib/services/item_size_validator_service"

RSpec.describe ItemSizeValidatorService do
  let(:serialized_item) do
    {
      "id" => "123",
      "title" => "Short title"
    }
  end

  describe ".call" do
    it "returns the JSON payload when it fits within the size limit" do
      max_bytes = serialized_item.to_json.bytesize + 10

      result = described_class.call(serialized_item, max_bytes: max_bytes)

      expect(result).to eq(serialized_item.to_json)
    end

    it "raises SizeItemError when the payload exceeds the limit" do
      max_bytes = serialized_item.to_json.bytesize - 1

      expect do
        described_class.call(serialized_item, max_bytes: max_bytes)
      end.to raise_error(
        described_class::SizeItemError,
        "Item 123 exceeds maximum batch size"
      )
    end
  end
end
