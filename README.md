# Publitas XML Processor

Publitas XML Processor is a small Ruby application that reads product feeds,
parses them with Nokogiri, and sends validated batches to an external service.
The project targets Ruby 2.x and ships with a simple example feed to get you
started quickly.

## Prerequisites

- Ruby 2.5 or newer
- Bundler (`gem install bundler` if you do not already have it)

## Setup

Install the project dependencies:

```sh
bundle install
```

## Usage

Run the processor against the sample XML feed (or point it at your own feed):

```sh
bundle exec ruby bin/assignment.rb resources/feed.xml
```

The command prints processing progress to STDOUT. To process a different feed,
replace `resources/feed.xml` with the path to your XML file.

## Tests

Execute the RSpec suite to verify the implementation:

```sh
bundle exec rspec
```

## Project Structure

- `bin/assignment.rb` — CLI entry point that invokes `ProcessXmlService`.
- `lib/process_xml_service.rb` — orchestrates reading, validating, serializing, validating size, and batching XML items.
- `lib/services/item_reader_service.rb` — streams XML files and yields `<item>` nodes.
- `lib/services/item_fields_validator_service.rb` — ensures required fields (currently `g:id` and `title`) are present.
- `lib/services/item_serializer_service.rb` — extracts relevant fields from an item node into a Ruby hash.
- `lib/services/item_size_validator_service.rb` — checks the serialized payload stays within the batch size limit.
- `lib/services/process_item_data_service.rb` — accumulates item JSON strings and flushes them to the external service.
- `lib/external/external_service.rb` — stubbed downstream integration that receives batched payloads.

## Implementation details

- It would be good to support multiple kinds of external services, but following YAGNI, I didn’t add extra parameters.
- item_reader_service is responsible for reading and parsing XML streams. For extensibility, it could support different XML formats, but according to the test task requirements and following YAGNI and KISS I kept it simple.
- I planned to add XSD validation but couldn’t find a suitable XSD file.
- I decided to not write separate error handler which will just print the error message as to the KISS. So in case different errors will require different handling it will require to init such service.
- Current implementaion sticks to existing example xml format with namespace for some fields like `id`, and won't work if change it to `id` without `g` namespace. I decided to not raise code compexity because of this case.
- There is not pretty code which assigns serialized data, then assigns transformed to JSON data and there is additional id parameter. It is done to keep meaningful error message with `id` and not duplicate `to_json` operation.
