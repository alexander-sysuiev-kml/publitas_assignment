# frozen_string_literal: true

require "nokogiri"
require_relative "item_reader_service"
require_relative "item_validator_service"
require_relative "process_item_data_service"
require_relative "utils/callable"

class ProcessXmlService
  include Utils::Callable

  def initialize(xml_file_path)
    @xml_file_path = xml_file_path
    @item_processor = ProcessItemDataService.new
  end

  def call
    process_items
    item_processor.flush
  end

  private

  attr_reader :item_processor

  def process_items
    ItemReaderService.call(@xml_file_path) do |item_node|
      validated_item = ItemValidatorService.call(item_node)
      item_processor.store_item(validated_item)
    rescue *expected_errors => e
      warn "Skipping invalid item: #{e.message}"
    end
  end

  def expected_errors
    [
      Nokogiri::XML::SyntaxError,
      ItemValidatorService::InvalidItemError,
      ItemSerializerService::SerializeItemError
    ]
  end
end
