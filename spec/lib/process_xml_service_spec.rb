# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../../lib/process_xml_service"

RSpec.describe ProcessXmlService do
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:invalid_feed_path) { File.expand_path("../fixtures/invalid_feed.xml", __dir__) }
  let(:with_invalid_feed_path) { File.expand_path("../fixtures/with_invalid_feed.xml", __dir__) }
  let(:item_processor) { instance_double(ProcessItemDataService, store_item: nil, flush: nil) }
  let(:xml_path) { valid_feed_path }
  let(:service) { described_class.new(xml_path) }

  describe "#call" do
    before do
      allow(ProcessItemDataService).to receive(:new).and_return(item_processor)
      allow(service).to receive(:warn)
    end

    context "with only valid items" do
      it "delegates each validated item to the item processor and flushes once" do
        service.call

        expect(item_processor).to have_received(:store_item).twice
        expect(item_processor).to have_received(:flush).once
        expect(service).not_to have_received(:warn)
      end
    end

    context "when an invalid item is present" do
      let(:xml_path) { with_invalid_feed_path }

      it "warns and skips invalid items while continuing with valid ones" do
        service.call

        expect(item_processor).to have_received(:store_item).twice
        expect(item_processor).to have_received(:flush).once
        expect(service).to have_received(:warn).with(/Skipping invalid item/)
      end
    end

    context "with only invalid items" do
      let(:xml_path) { invalid_feed_path }

      it "skips processing and warns for every invalid item" do
        service.call

        expect(item_processor).not_to have_received(:store_item)
        expect(item_processor).to have_received(:flush).once
        expect(service).to have_received(:warn).with(/Skipping invalid item/)
      end
    end

    it "raises an error when the XML file cannot be opened" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "missing.xml")
        missing_service = described_class.new(path)

        expect { missing_service.call }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
