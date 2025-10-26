# Publitas XML Processor

Simple Ruby project that parses XML files and extracts information. The project targets Ruby 2.x and relies on Bundler to manage the `nokogiri` XML parsing dependency.

## Requirements

- Ruby 2.x (2.5 or newer is recommended)
- Bundler (`gem install bundler` if not already available)

## Setup

```sh
bundle install
```

## Usage

Run the sample processor against the provided example XML file:

```sh
bundle exec ruby bin/assignment.rb resources/feed.xml
```

## Test

Run Rspec test

```sh
bundle exec rspec
```

## Implementation details

- process_xml_service is a main orchestration service
- would be good to support different external services, but as to YAGNI I ddin't add additional parameters
- process_item_data_service is responsible for batches calculation and sending it to external_service
- item_validator_service is responsible for single item validation. At the moment my assumption that id and title should be present and description could be blank.
- item_reader_service is responsible for reading and parsing xml in stream. For extandability could be good to add different formats read possibility, but as to test task requirements and as to YAGNI and KISS left it simple.
- I planned to add xsd validation but I haven't found the proper xsd
