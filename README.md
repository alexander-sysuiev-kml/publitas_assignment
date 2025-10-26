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

- `bin/assignment.rb` — CLI entry point that wires together the processing flow.
- `lib/process_xml_service.rb` — orchestrates reading, validating, and sending XML items.
- `lib/process_item_data_service.rb` — batches serialized items and forwards them to `ExternalService`.
- `lib/item_validator_service.rb` — enforces that each item contains an `id` and `title`; `description` is optional. (according to author assumptions)
- `lib/item_reader_service.rb` — streams and parses XML input using Nokogiri.
- `lib/item_serializer_service.rb` — converts XML item nodes to JSON while enforcing payload size limits.
- `lib/external_service.rb` — stubbed integration point for downstream delivery.

## Implementation details

- It would be good to support multiple kinds of external services, but following YAGNI, I didn’t add extra parameters.
- item_reader_service is responsible for reading and parsing XML streams. For extensibility, it could support different XML formats, but according to the test task requirements and following YAGNI and KISS I kept it simple.
- I planned to add XSD validation but couldn’t find a suitable XSD file.
- I decided to not write separate error handler which will just print the error message as to the KISS. So in case different errors will require different handling it will require to init such service.
- Current implementaion sticks to existing example xml format with namespace for sime fields like `id`, and won't work if change it to `id` without `g` namespace. I decided to not raise code compexity because of this case.
