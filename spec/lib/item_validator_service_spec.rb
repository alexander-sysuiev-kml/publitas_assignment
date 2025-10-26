# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/item_validator_service"

RSpec.describe ItemValidatorService do
  describe ".call" do
    let(:document) do
      Nokogiri::XML(<<~XML)
        <item xmlns:g="http://base.google.com/ns/1.0">
          <g:id>123</g:id>
          <title>Valid</title>
          <description>Valid description</description>
        </item>
      XML
    end
    let(:invalid_item_document) do
      Nokogiri::XML(<<~XML)
        <item xmlns:g="http://base.google.com/ns/1.0">
          <g:id>123</g:id>
          <title>Valid</title>
        </item>
      XML
    end

    it "returns the document when all required fields are present" do
      result = described_class.call(document)
      expect(result).to equal(document)
    end

    it "raises InvalidItemError when required fields are missing" do
      expect { described_class.call(invalid_item_document) }
        .to raise_error(described_class::InvalidItemError) { |error|
          expect(error.missing_fields).to include("description")
        }
    end
  end
end
