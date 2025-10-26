# frozen_string_literal: true

require "json"
require "nokogiri"
require "spec_helper"
require_relative "../../lib/process_item_data_service"

RSpec.describe ProcessItemDataService do
  let(:external_service) { instance_double(ExternalService, call: nil) }
  subject(:service) { described_class.new(external_service: external_service) }
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:valid_item_documents) do
    Nokogiri::XML(File.read(valid_feed_path)).xpath("//item").map { |node| Nokogiri::XML(node.to_xml) }
  end

  describe "#call and #flush" do
    let(:payloads) { [] }

    before do
      allow(external_service).to receive(:call) { |payload| payloads << payload }
    end

    it "serializes items to JSON and delivers them to the external service on flush" do
      stub_const("ProcessItemDataService::BATCH_SIZE_BYTES", 10_000)

      service.call(valid_item_documents.first)
      service.flush

      expect(payloads.size).to eq(1)
      parsed_payload = JSON.parse(payloads.first)
      expect(parsed_payload).to eq(
        [
          {
            "g:id" => "1",
            "title" => "First item",
            "link" => "https://example.com/first",
            "description" => "First item description"
          }
        ]
      )
    end

    it "automatically flushes when the batch payload size exceeds the threshold" do
      stub_const("ProcessItemDataService::BATCH_SIZE_BYTES", 60)
      allow(service).to receive(:serialize_item).and_return(
        '{"item":"aaaaaaaaaa"}',
        '{"item":"bbbbbbbbbb"}',
        '{"item":"cccccccccc"}'
      )

      document = Nokogiri::XML("<item/>")

      3.times { service.call(document) }

      expect(payloads.size).to eq(1)
      expect(JSON.parse(payloads.first).size).to eq(2)

      service.flush

      expect(payloads.size).to eq(2)
      expect(JSON.parse(payloads.last).size).to eq(1)
    end
  end
end
