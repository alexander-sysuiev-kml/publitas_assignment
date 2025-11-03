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
- `ItemReaderService` is responsible for reading and parsing XML streams. For extensibility, it could support different XML formats, but according to the test task requirements and following YAGNI and KISS, I kept it simple.
- I planned to add XSD validation but couldn’t find a suitable XSD file.
- I decided not to write a separate error handler that would just print the error message, in the spirit of KISS. If different errors require different handling in the future, such a service can be introduced.
- The current implementation sticks to the existing example XML format with a namespace for some fields like `g:id`, and it won't work if changed to `id` without the `g` namespace. I decided not to increase code complexity because of this case.
- There is some not so pretty code in `process_items` that assigns serialized data, then assigns the transformed JSON data, and passes an additional `id` parameter. This keeps a meaningful error message with `id` and avoids duplicating the `to_json` operation.
- If a single item doesn't fit the 5MB size limit, it is skipped.
- Based on the feed analysis, many records do not have `description`, so I decided to make this field optional.
- In my opinion, without `title` a record doesn't make sense, so I made `title` required despite some records lacking this field.
- If a record is not valid, it is skipped and does not break the overall process.
