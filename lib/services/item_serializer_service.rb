# frozen_string_literal: true

require "json"
require_relative "../utils/callable"

class ItemSerializerService
  include Utils::Callable

  def initialize(item_document)
    @item_document = item_document
  end

  def call
    {
      "id" => extract_field("g:id"),
      "title" => extract_field("title"),
      "description" => extract_field("description")
    }
  end

  private

  attr_reader :item_document

  def extract_field(field)
    item_document.at_xpath("//item/#{field}")&.text&.strip
  end
end
