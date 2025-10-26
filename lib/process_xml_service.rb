# frozen_string_literal: true

require "nokogiri"
require_relative "services/item_reader_service"
require_relative "services/item_fields_validator_service"
require_relative "services/process_item_data_service"
require_relative "services/item_size_validator_service"
require_relative "utils/callable"

class ProcessXmlService
  include Utils::Callable

  BATCH_SIZE_BYTES = (5 * 1_048_576).to_i

  def initialize(xml_file_path)
    @xml_file_path = xml_file_path
    @item_processor = ProcessItemDataService.new(max_bytes: BATCH_SIZE_BYTES)
  end

  def call
    process_items
    item_processor.flush
  end

  private

  attr_reader :item_processor

  def process_items
    ItemReaderService.call(@xml_file_path) do |item_node|
      ItemFieldsValidatorService.call(item_node)
      serialized_item = ItemSerializerService.call(item_node)
      json_data = serialized_item.to_json

      ItemSizeValidatorService.call(
        # To not duplicate to_json operation
        serialized_item["id"],
        json_data,
        max_bytes: BATCH_SIZE_BYTES
      )

      item_processor.store_item(json_data)
    rescue *expected_errors => e
      warn "Skipping invalid item: #{e.message}"
    end
  end

  def expected_errors
    [
      Nokogiri::XML::SyntaxError,
      ItemFieldsValidatorService::InvalidItemError,
      ItemSizeValidatorService::SizeItemError,
    ]
  end
end
