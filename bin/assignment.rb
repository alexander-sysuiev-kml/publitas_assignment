#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require_relative "../lib/process_xml_service"

def usage
  warn "Usage: bin/process_catalog PATH_TO_XML_FILE"
  exit 1
end

usage if ARGV.length != 1

xml_path = ARGV.fetch(0)

processor = ProcessXmlService.new(xml_path)

puts "Feed items:"
processor.call
