# Internal: This class is responsible for sanitizing and forcibly encoding
# strings of text received into UTF-8.
module Aldrich
  class Sanitizer
    attr_reader :import_name, :csv_file

    # Public: Scrub a file of all invalid characters (within the scope of the
    # Importer).
    #
    # spreadsheet - A File object containing import data.
    #
    # Examples
    #
    #   spreadsheet = File.open('/tmp/import.csv')
    #   Sanitizer.valid_utf8(spreadsheet)
    #   # => #<TempFile:0x9834>
    #
    # Returns a TempFile object with the contents of the original file coerced
    # to UTF-8.
    def self.valid_utf8(import_name, csv_file)
      new(import_name, csv_file).sanitized_file
    end

    def initialize(import_name, csv_file)
      @import_name = import_name
      @csv_file    = csv_file
    end

    def sanitized_file
      Tempfile.new([temp_name, '.csv']).tap do |file|
        file.write(sanitized_contents)
        file.rewind
      end
    end

    def sanitized_contents
      encoding_options = {
        invalid: :replace,
        undef:   :replace,
        replace: ''
      }

      file_contents.encode('UTF-8', 'binary', encoding_options)
    end

    private

    def file_contents
      @file_contents ||= csv_file.read
    end

    # NOTE (JamesChristie) Some files will have characters, such as a forward
    # slash, that are not safe for path name segments
    def temp_name
      "#{slugged_import_name}_#{timestamp}".gsub(/[^0-9A-Za-z.\-]/, '_')
    end

    def slugged_import_name
      Util.underscore(import_name).downcase.gsub(' ', '_')
    end

    def timestamp
      Time.now.strftime("%Y%m%d_%H%M")
    end
  end
end
