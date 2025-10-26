# frozen_string_literal: true

require_relative "../external/external_service"
require_relative "item_serializer_service"

class ProcessItemDataService
  BATCH_SIZE_BYTES = (5 * 1_048_576).to_i

  SerializeItemError = ItemSerializerService::SerializeItemError

  def initialize(item_serializer: ItemSerializerService)
    @external_service = ExternalService.new
    @item_serializer = item_serializer
    reset_batch
  end

  def store_item(item_document)
    serialized_item = item_serializer.call(item_document, max_bytes: BATCH_SIZE_BYTES)
    enqueue(serialized_item)
  end

  def flush
    send_batch if @batch_items.any?
  end

  private

  attr_reader :external_service, :item_serializer

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

  def calculate_projected_size(item_serialized)
    comma_bytes = @batch_items.empty? ? 0 : 1
    @current_payload_bytes + item_serialized.bytesize + comma_bytes
  end

  def fits_in_batch?(projected_size)
    projected_size <= BATCH_SIZE_BYTES
  end
end
