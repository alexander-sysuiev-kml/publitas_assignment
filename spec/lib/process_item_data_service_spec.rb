# frozen_string_literal: true

require "json"
require "spec_helper"
require_relative "../../lib/services/process_item_data_service"

RSpec.describe ProcessItemDataService do
  let(:external_service) { instance_double(ExternalService, call: nil) }
  let(:serialized_item) { { "id" => "1", "title" => "First item" }.to_json }
  subject(:service) { described_class.new }

  before do
    allow(ExternalService).to receive(:new).and_return(external_service)
  end

  describe "#store_item" do
    it "enqueues the serialized item for batching" do
      service.store_item(serialized_item)

      expect(service.instance_variable_get(:@batch_items)).to eq([serialized_item])
    end

    it "flushes the current batch when the next item would exceed the limit" do
      stub_const("ProcessItemDataService::BATCH_SIZE_BYTES", serialized_item.bytesize + 4)
      service = described_class.new

      service.store_item(serialized_item)
      service.store_item(serialized_item)

      expect(external_service).to have_received(:call).with("[#{serialized_item}]")
      expect(service.instance_variable_get(:@batch_items)).to eq([serialized_item])
    end
  end

  describe "#flush" do
    it "delivers the accumulated payload to the external service" do
      service.store_item(serialized_item)

      service.flush

      expect(service.instance_variable_get(:@batch_items)).to be_empty
      expect(external_service).to have_received(:call).with("[#{serialized_item}]")
    end
  end
end
