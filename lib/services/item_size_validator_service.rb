# frozen_string_literal: true

require "nokogiri"
require_relative "../utils/callable"

class ItemSizeValidatorService
  include Utils::Callable

  class SizeItemError < StandardError; end

  def initialize(serialized_item, max_bytes:)
    @serialized_item = serialized_item
    @max_bytes = max_bytes
  end

  def call
    item_data = serialized_item.to_json

    raise SizeItemError, "Item #{serialized_item["id"]} exceeds maximum batch size" if item_data.bytesize > max_bytes

    item_data
  end

  private

  attr_reader :serialized_item, :max_bytes
end
