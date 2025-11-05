# frozen_string_literal: true

require "nokogiri"
require_relative "../utils/callable"

class ItemSizeValidatorService
  include Utils::Callable

  BRACKET_BYTES = 2

  class SizeItemError < StandardError; end

  def initialize(id, serialized_item, max_bytes:)
    @id = id
    @serialized_item = serialized_item
    @max_bytes = max_bytes
  end

  def call
    raise SizeItemError, "Item #{@id} exceeds maximum batch size" if @serialized_item.bytesize + BRACKET_BYTES > @max_bytes
  end

  private

  attr_reader :serialized_item, :max_bytes
end
