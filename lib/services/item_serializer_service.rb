# frozen_string_literal: true

require "json"
require_relative "../utils/callable"

class ItemSerializerService
  include Utils::Callable

  class SerializeItemError < StandardError; end

  def initialize(item_document, max_bytes:)
    @item_document = item_document
    @max_bytes = max_bytes
  end

  def call
    id = extract_field("g:id")
    data = {
      "id" => id,
      "title" => extract_field("title"),
      "description" => extract_field("description")
    }.to_json

    raise SerializeItemError, "Serialized item #{id} exceeds maximum batch size" if data.bytesize > max_bytes

    data
  end

  private

  attr_reader :item_document, :max_bytes

  def extract_field(field)
    item_document.at_xpath("//item/#{field}")&.text&.strip
  end
end
