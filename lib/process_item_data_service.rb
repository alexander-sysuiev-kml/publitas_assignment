# frozen_string_literal: true

require "json"
require_relative "external_service"
require_relative "utils/callable"

class ProcessItemDataService
  BATCH_SIZE_BYTES = (5 * 1_048_576).to_i

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
    @payload_size = 2 # for surrounding brackets in JSON array
  end

  def enqueue(serialized_item)
    comma_bytes = @batch_items.empty? ? 0 : 1
    projected_size = @payload_size + serialized_item.bytesize + comma_bytes

    if projected_size > BATCH_SIZE_BYTES
      send_batch
      projected_size = @payload_size + serialized_item.bytesize
    end

    @batch_items << serialized_item
    @payload_size = projected_size
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
      raise "Serialized item #{id} exceeds maximum batch size"
    end

    data
  end

  def extract_field(item_document, field)
    item_document.at_xpath("//item/#{field}")&.text&.strip  
  end
end
