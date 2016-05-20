# Internal: CasualJacket requires configured context to use headers from a
# CSV file to translate each row into an operation. This translation stage
# is included such that data can be standardized from headers that
# represent a human readable title for each value.
#
# This class performs the translation for literal field information as provided
# by the POST request to submit a new import job. It also sanitizes Windows
# line ending and any other garbage data browsers will often apply to
# string data in JSON hashes.
module Aldrich
  module Factories
    class FieldLegend
      attr_reader :field_headers

      # Public: Produce a header legend Hash given field header context
      #
      # field_headers - The context Hash to be translated
      #
      # Examples:
      #
      #   field_headers = {
      #     "upc_code"    => "UPC Code",
      #     "name"        => "Product Name",
      #     "description" => "Product Name"
      #   }
      #
      #   Importer::Factories::FieldLegend.translated_fields(field_headers)
      #   # => {
      #     "UPC Code"     => ["upc_code"],
      #     "Product Name" => ["name", "description"]
      #   }
      def self.translated_fields(field_headers)
        new(field_headers).translated_fields
      end

      def initialize(field_headers)
        @field_headers = field_headers
      end

      def translated_fields
        stripped_field_headers.each_with_object({}) do |(field, header), legend|
          clean_header = header.chomp
          legend[clean_header] ||= []
          legend[clean_header] << field
        end
      end

      private

      def stripped_field_headers
        field_headers.delete_if { |field, header| header.empty? }
      end
    end
  end
end
