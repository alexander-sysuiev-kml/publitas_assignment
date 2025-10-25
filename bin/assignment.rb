#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "../lib/xml_processor"

def usage
  warn "Usage: bin/process_catalog PATH_TO_XML_FILE"
  exit 1
end

usage if ARGV.length != 1

xml_path = ARGV.fetch(0)

processor = XmlProcessor.new(xml_path)

puts "Feed items:"
processor.items
