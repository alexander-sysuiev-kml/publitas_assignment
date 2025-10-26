class ItemReaderService
  def self.call(xml_file_path)
    File.open(xml_file_path) do |io|
      reader = Nokogiri::XML::Reader(io)
      reader.each do |node|
        next unless node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        next unless node.name == "item"

        yield Nokogiri::XML(node.outer_xml) if block_given?
      end
    end
  end
end
