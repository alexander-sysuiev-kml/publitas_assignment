# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../../lib/xml_processor"

RSpec.describe XmlProcessor do
  let(:valid_feed_path) { File.expand_path("../fixtures/sample_feed.xml", __dir__) }
  let(:invalid_feed_path) { File.expand_path("../fixtures/invalid_feed.xml", __dir__) }

  describe "#initialize" do
    it "loads the XML document from disk" do
      processor = described_class.new(valid_feed_path)
      expect(processor).to be_a(described_class)
    end

    it "raises an ArgumentError when the file cannot be read" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "nonexistent.xml")

        expect { described_class.new(path) }
          .to raise_error(ArgumentError, /Could not read XML from #{Regexp.escape(path)}/)
      end
    end

    it "raises an error when the XML is invalid" do
      expect { described_class.new(invalid_feed_path) }
        .to raise_error(Nokogiri::XML::SyntaxError)
    end
  end

  describe "#items" do
    subject(:processor) { described_class.new(valid_feed_path) }

    it "returns all catalog items from the feed" do
      expect(processor.items).to be_an(Array)
      expect(processor.items.size).to eq(2)
    end

    it "memoizes the parsed items" do
      allow(processor).to receive(:puts)

      first = processor.items
      second = processor.items

      expect(second).to equal(first)
      expect(processor).to have_received(:puts).exactly(2).times
    end
  end
end
