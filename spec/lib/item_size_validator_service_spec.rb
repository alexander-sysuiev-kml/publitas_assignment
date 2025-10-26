# frozen_string_literal: true

require "json"
require "spec_helper"
require_relative "../../lib/services/item_size_validator_service"

RSpec.describe ItemSizeValidatorService do
  let(:item_id) { "123" }
  let(:serialized_item) { { "id" => item_id, "title" => "Short title" }.to_json }

  describe ".call" do
    it "does not raise when the payload fits within the size limit" do
      max_bytes = serialized_item.bytesize + 10

      expect do
        described_class.call(item_id, serialized_item, max_bytes: max_bytes)
      end.not_to raise_error
    end

    it "raises SizeItemError when the payload exceeds the limit" do
      max_bytes = serialized_item.bytesize - 1

      expect do
        described_class.call(item_id, serialized_item, max_bytes: max_bytes)
      end.to raise_error(
        described_class::SizeItemError,
        "Item 123 exceeds maximum batch size"
      )
    end
  end
end
