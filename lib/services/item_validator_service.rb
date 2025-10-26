# frozen_string_literal: true

require "nokogiri"
require_relative "../utils/callable"

class ItemValidatorService
  include Utils::Callable

  REQUIRED_FIELDS = %w[g:id title].freeze

  class InvalidItemError < StandardError
    attr_reader :missing_fields

    def initialize(missing_fields)
      @missing_fields = missing_fields
      super("Item is missing required fields: #{missing_fields.join(', ')}")
    end
  end

  def initialize(item_document)
    @item_document = item_document
  end

  def call
    missing_fields = REQUIRED_FIELDS.reject { |field| field_present?(field) }
    return item_document if missing_fields.empty?

    raise InvalidItemError, missing_fields
  end

  private

  attr_reader :item_document

  def field_present?(field)
    item_document.at_xpath("//item/#{field}")&.text&.strip&.length.to_i.positive?
  end
end
