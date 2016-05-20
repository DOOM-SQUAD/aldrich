# Internal: CasualJacket requires configured context to use headers from a
# CSV file to translate each row into an operation. This translation stage
# is included such that data can be standardized from headers that
# represent a human readable title for each value.
#
# This class performs the translation for attribute information as provided
# by the POST request to submit a new import job. It also sanitizes Windows
# line ending and any other garbage data browsers will often apply to
# string data in JSON hashes.
module Aldrich
  module Factories
    class AttributeLegend
      attr_reader :attribute_context

      # Public: Produce a header legend Hash given attribute contexts.
      #
      # attribute_context - the context Hash to be translated
      #
      # attribute_context = {
      #   "Color" => { "name" => "Color", "code" => "Color" },
      #   "Size"  => { "name" => "Size", "code" => "Size Code" },
      #   "Width" => { "name" => "", "code" => "" }
      # }
      #
      # Importer::LengendFactory.translated_attributes(attribute_context)
      # => {
      #      "Color"     => ["color_attribute_name", "color_attribute_code"],
      #      "Size"      => ["size_attribute_name"],
      #      "Size Code" => ["size_attribute_code"]
      #    }
      #
      # Returns the translated Hash of headers.
      def self.translated_attributes(attribute_context)
        new(attribute_context).translated_attributes
      end

      def initialize(attribute_context)
        @attribute_context = attribute_context
      end

      def translated_attributes
        inverted_attribute_context.delete_if do |header, attribute_list|
          header.empty?
        end
      end

      private

      def inverted_attribute_context
        attribute_context.each_with_object({}) do |(attribute_name, header_context), legend|
          legend.merge! inverted_header_context(attribute_name, header_context)
        end
      end

      def inverted_header_context(attribute_name, header_context)
        header_context.each_with_object({}) do |(key, header_string), context|
          safe_header = header_string.chomp
          context[safe_header] ||= []
          context[safe_header] << attribute_key_string(attribute_name, key)
        end
      end

      def attribute_key_string(attribute_name, key)
        "#{Util.underscore(attribute_name)}_attribute_#{key}"
      end
    end
  end
end
