# frozen_string_literal: true

require "json"
require_relative "external_service"
require_relative "utils/callable"

class ProcessItemDataService
  BATCH_SIZE_BYTES = (5 * 1_048_576).to_i

  class SerializeItemError < StandardError; end

  def initialize
    @external_service = ExternalService.new
    reset_batch
  end

  def store_item(item_document)
    serialized_item = serialize_item(item_document)
    enqueue(serialized_item)
  end

  def flush
    send_batch if @batch_items.any?
  end

  private

  attr_reader :external_service

  def reset_batch
    @batch_items = []
    @current_payload_bytes = 2 # accounts for surrounding brackets in JSON array
  end

  def enqueue(serialized_item)
    projected_size = calculate_projected_size(serialized_item)

    unless fits_in_batch?(projected_size)
      send_batch
      projected_size = calculate_projected_size(serialized_item)
    end

    @batch_items << serialized_item
    @current_payload_bytes = projected_size
  end

  def send_batch
    payload = "[#{@batch_items.join(',')}]"
    external_service.call(payload)
    reset_batch
  end

  def serialize_item(item_document)
    id = extract_field(item_document, "g:id")
    data = {
      "id" => id,
      "title" => extract_field(item_document, "title"),
      "description" => extract_field(item_document, "description")
    }.to_json

    if data.bytesize > BATCH_SIZE_BYTES
      raise SerializeItemError.new("Serialized item #{id} exceeds maximum batch size")
    end

    data
  end

  def extract_field(item_document, field)
    item_document.at_xpath("//item/#{field}")&.text&.strip
  end

  def calculate_projected_size(item_serialized)
    comma_bytes = @batch_items.empty? ? 0 : 1
    @current_payload_bytes + item_serialized.bytesize + comma_bytes
  end

  def fits_in_batch?(projected_size)
    projected_size <= BATCH_SIZE_BYTES
  end
end
