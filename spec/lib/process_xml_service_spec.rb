# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/process_xml_service"
require "tmpdir"

RSpec.describe ProcessXmlService do
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:invalid_feed_path) { File.expand_path("../fixtures/invalid_feed.xml", __dir__) }

  describe "#call" do
    subject(:service) { described_class.new(valid_feed_path) }

    before do
      allow(service).to receive(:puts)
      allow(service).to receive(:warn)
    end

    it "parses each item from the XML feed and stores the documents" do
      service.call

      documents = service.instance_variable_get(:@document)
      expect(documents.size).to eq(2)
      expect(documents).to all(be_a(Nokogiri::XML::Document))
      expect(service).to have_received(:puts).twice
      expect(service).not_to have_received(:warn)
    end

    it "warns and skips items that are missing required fields" do
      invalid_item_node = Nokogiri::XML(File.read(invalid_feed_path)).at_xpath("//item")
      valid_item_document = Nokogiri::XML("<item xmlns:g=\"http://base.google.com/ns/1.0\"><g:id>2</g:id><title>Valid</title><description>Valid</description></item>")

      allow(ItemReaderService)
        .to receive(:call)
        .with(valid_feed_path)
        .and_yield(Nokogiri::XML(invalid_item_node.to_xml))
        .and_yield(valid_item_document)

      service.call

      documents = service.instance_variable_get(:@document)
      expect(documents.size).to eq(1)
      expect(service).to have_received(:warn).with(/Skipping invalid item/)
      expect(service).to have_received(:puts).once
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
