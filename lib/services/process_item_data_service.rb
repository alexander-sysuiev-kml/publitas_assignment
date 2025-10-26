# frozen_string_literal: true

require_relative "../external/external_service"
require_relative "item_serializer_service"

class ProcessItemDataService
  BATCH_SIZE_BYTES = (5 * 1_048_576).to_i

  SerializeItemError = ItemSerializerService::SerializeItemError

  def initialize(max_bytes: BATCH_SIZE_BYTES)
    @external_service = ExternalService.new
    @max_bytes = max_bytes
    reset_batch
  end

  def store_item(serialized_item)
    enqueue(serialized_item)
  end

  def flush
    send_batch if @batch_items.any?
  end

  private

  attr_reader :external_service, :item_serializer

  def reset_batch
    @batch_items = []
    @current_payload_bytes = 2 # for surrounding brackets in JSON array
  end

  def enqueue(serialized_item)
    send_if_fits_in_batch(serialized_item)

    @batch_items << serialized_item
    @current_payload_bytes = calculate_projected_size(serialized_item)
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

  def send_if_fits_in_batch(serialized_item)
    return if calculate_projected_size(serialized_item) < BATCH_SIZE_BYTES

    send_batch
  end
end
