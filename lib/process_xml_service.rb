# frozen_string_literal: true

require "nokogiri"
require_relative "item_reader_service"
require_relative "item_validator_service"

class ProcessXmlService
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
      ItemValidatorService.call(item_node)
      puts item_node
      @document << item_node
    rescue Nokogiri::XML::SyntaxError, ItemValidatorService::InvalidItemError => e
      warn "Skipping invalid item: #{e.message}"
    end
  end
end
