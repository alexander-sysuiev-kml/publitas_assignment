# frozen_string_literal: true

require "json"
require "nokogiri"
require "spec_helper"
require_relative "../../lib/process_item_data_service"

RSpec.describe ProcessItemDataService do
  let(:external_service) { instance_double(ExternalService, call: nil) }
  subject(:service) { described_class.new }
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:valid_item_documents) do
    Nokogiri::XML(File.read(valid_feed_path)).xpath("//item")
  end

  describe "#call and #flush" do
    let(:expected_payload) do
      [
        {
          "id" => "1",
          "title" => "First item",
          "description" => "First item description"
        }
      ].to_json
    end

    before do
      allow(ExternalService).to receive(:new).and_return(external_service)
    end

    it "serializes items to JSON and delivers them to the external service on flush" do
      stub_const("ProcessItemDataService::BATCH_SIZE_BYTES", 10_000)

      service.store_item(valid_item_documents.first)
      expect(service.instance_variable_get(:@batch_items).size).to eq(1)
      service.flush
      expect(service.instance_variable_get(:@batch_items).size).to eq(0)
      expect(external_service).to have_received(:call).with(expected_payload)
    end
  end
end
