require "nokogiri"
require_relative "utils/callable"

class ItemReaderService
  include Utils::Callable

  def initialize(xml_file_path)
    @xml_file_path = xml_file_path
  end

  def call
    File.open(@xml_file_path) do |io|
      reader = Nokogiri::XML::Reader(io)
      reader.each do |node|
        next unless node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        next unless node.name == "item"

        yield Nokogiri::XML(node.outer_xml) if block_given?
      end
    end
  end
end
