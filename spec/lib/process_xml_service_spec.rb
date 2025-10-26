# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../../lib/process_xml_service"

RSpec.describe ProcessXmlService do
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:invalid_feed_path) { File.expand_path("../fixtures/invalid_feed.xml", __dir__) }
  let(:item_processor) { instance_double(ProcessItemDataService, call: nil, flush: nil) }
  let(:service) { described_class.new(valid_feed_path, item_processor: item_processor) }
  let(:valid_item_documents) do
    Nokogiri::XML(File.read(valid_feed_path)).xpath("//item").map { |node| Nokogiri::XML(node.to_xml) }
  end
  let(:invalid_item_document) do
    node = Nokogiri::XML(File.read(invalid_feed_path)).at_xpath("//item")
    Nokogiri::XML(node.to_xml)
  end

  describe "#call" do
    before do
      allow(service).to receive(:puts)
      allow(service).to receive(:warn)
    end

    context "with only valid items" do
      before do
        allow(ItemReaderService).to receive(:call).with(valid_feed_path) do |_, &block|
          valid_item_documents.each { |document| block.call(document) }
        end
      end

      it "delegates each validated item to the item processor and flushes once" do
        service.call

        valid_item_documents.each do |document|
          expect(item_processor).to have_received(:call).with(document)
        end
        expect(item_processor).to have_received(:flush).once
        expect(service).to have_received(:puts).twice
        expect(service).not_to have_received(:warn)
      end
    end

    context "when an invalid item is present" do
      before do
        allow(ItemReaderService).to receive(:call).with(valid_feed_path) do |_, &block|
          block.call(invalid_item_document)
          block.call(valid_item_documents.first)
        end
      end

      it "warns and skips invalid items while continuing with valid ones" do
        service.call

        expect(item_processor).to have_received(:call).with(valid_item_documents.first)
        expect(item_processor).to have_received(:call).once
        expect(item_processor).to have_received(:flush).once
        expect(service).to have_received(:warn).with(/Skipping invalid item/)
        expect(service).to have_received(:puts).once
      end
    end

    it "raises an error when the XML file cannot be opened" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "missing.xml")
        missing_service = described_class.new(path, item_processor: item_processor)

        expect { missing_service.call }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
