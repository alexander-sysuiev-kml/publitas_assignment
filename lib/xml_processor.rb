# frozen_string_literal: true

require "nokogiri"

class XmlProcessor
  ITEM_XPATH = "//rss/channel/item"

  def initialize(xml_file_path)
    @document = load_document(xml_file_path)
    validate!
  end

  # Returns each catalog item.
  def items
    @items ||= @document.xpath(ITEM_XPATH).map do |node|
      puts node
    end
  end

  private

  def load_document(file_path)
    raw_xml = File.read(file_path)

    Nokogiri::XML(raw_xml) { |config| config.strict.noblanks }
  rescue Errno::ENOENT => e
    raise ArgumentError, "Could not read XML from #{file_path}: #{e.message}"
  end

  def validate!
    raise "Invalid XML document" unless @document.errors.empty?
  end
end

