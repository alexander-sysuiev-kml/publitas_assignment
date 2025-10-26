# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/services/item_fields_validator_service"

RSpec.describe ItemFieldsValidatorService do
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
          <description>Valid</description>
        </item>
      XML
    end

    it "does not raise when all required fields are present" do
      result = described_class.call(document)
      expect(result).to be_nil
    end

    it "raises InvalidItemError when required fields are missing" do
      expect { described_class.call(invalid_item_document) }
        .to raise_error(described_class::InvalidItemError) { |error|
          expect(error.missing_fields).to contain_exactly("title")
        }
    end
  end
end
