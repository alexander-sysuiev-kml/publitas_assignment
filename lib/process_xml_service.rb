# frozen_string_literal: true

require "nokogiri"
require_relative "item_reader_service"

class ProcessXmlService
  ITEM_XPATH = "//rss/channel/item"

  def initialize(xml_file_path)
    @document = []
    @xml_file_path = xml_file_path
  end

  def call
    load_document
  end
    
  private

  def load_document
    ItemReaderService.call(@xml_file_path) do |item_node|
      validate_item!(item_node)
      puts item_node
      @document << item_node
    rescue Nokogiri::XML::SyntaxError, ArgumentError => e
      warn "Skipping invalid item: #{e.message}"
    end
  end

  def validate_item!(item_node)
    required_fields = %w[g:id title description]
    missing_fields = required_fields.reject { |field| item_node.at_xpath("//item/#{field}") }

    return if missing_fields.empty?

    raise ArgumentError, "Item is missing required fields: #{missing_fields.join(', ')}"
  end
end

