# Internal: This decorator provides extra functionality that is highly
# specific to the current implementation of the Importer service. Anything
# that did not make sense to provide in CasualJacket goes here
module Aldrich
  module Decorators
    class Operation
      extend Forwardable

      def_delegator :casual_jacket_operation, :id
      def_delegator :casual_jacket_operation, :group
      def_delegator :casual_jacket_operation, :attributes

      attr_reader :casual_jacket_operation

      def initialize(casual_jacket_operation)
        @casual_jacket_operation = casual_jacket_operation
      end

      # Public: Provides a list of names for Attribute models
      #
      # Returns an Array of Strings representing the names of attributes for a
      # Product
      def attribute_names
        trim_names(select_attribute_names)
      end

      # Public: Provides access the value data for a given attribute name
      #
      # name - A String representing the name of an attribute
      #
      # Returns a Hash of value data context
      def attribute(name)
        { name: attributes["#{name.downcase}#{ATTRIBUTE_NAME_POSTFIX}"],
          code: attributes["#{name.downcase}#{ATTRIBUTE_CODE_POSTFIX}"] }
      end

      # Public: Determines if any attribute information is present. Not just
      # configured, but values provided.
      #
      # Returns TrueClass or FalseClass
      def attributes_present?
        attribute_names.any? { |name| value_data_present?(name) }
      end

      # Public: Determines if the value data for an attribute is present in a
      # form sufficient to create an AttributeValue
      #
      # name - A String representing the name of an attribute
      #
      # Returns TrueClass or FalseClass
      def value_data_present?(name)
        !!attribute(name)[:name]
      end

      def image_urls_present?
        image_urls.present?
      end

      def image_urls
        split_images attributes.fetch(Aldrich::IMAGE_URLS, '')
      end

      # Public: Provides a list of all literal fields from an operation, e.g.
      # any fields that are unrelated to attributes or model that do not
      # directly represent sellable items in the catalog
      #
      # Returns a Hash representing literal fields and their values
      def literal_fields
        attributes.reject { |field, value| non_literal_field?(field) }
      end

      # Public: Provides access to values for a given field name
      #
      # Returns a String representing the raw value cached from the original
      # CSV file
      def value_for(name)
        attributes[name]
      end

      # Public: Determines if any form of tagging data is present
      #
      # Returns TrueClass or FalseClass
      def tag_data_present?
        !tag_replacement.empty? || !tag_additions.empty? || !tag_deletions.empty?
      end

      # Public: Provides a set of tags provided for replacement of the entire
      # existing tag set
      #
      # Returns an Array of Strings
      def tag_replacement
        split_tags attributes.fetch(Aldrich::TAGGING_REPLACE, '')
      end

      # Public: Provides a set of tags to be appended to the existing tag set
      #
      # Returns an Array of Strings
      def tag_additions
        split_tags attributes.fetch(Aldrich::TAGGING_APPEND, '')
      end

      # Public: Provides a set of tags to be removed from the existing tag set
      #
      # Returns an Array of Strings
      def tag_deletions
        split_tags attributes.fetch(Aldrich::TAGGING_DELETE, '')
      end

      private

      def non_literal_field?(field)
        select_attribute_fields.include?(field) || \
          tagging_fields.include?(field)        || \
          image_fields.include?(field)
      end

      def select_attribute_fields
        select_attribute_names + select_attribute_codes
      end

      def select_attribute_names
        attributes.keys.select { |key| key =~ /#{ATTRIBUTE_NAME_POSTFIX}$/ }
      end

      def select_attribute_codes
        attributes.keys.select { |key| key =~ /#{ATTRIBUTE_CODE_POSTFIX}$/ }
      end

      def tagging_fields
        [TAGGING_REPLACE, TAGGING_APPEND, TAGGING_DELETE]
      end

      def image_fields
        [IMAGE_URLS]
      end

      def trim_names(names)
        names.map do |name|
          name.gsub(ATTRIBUTE_NAME_POSTFIX, '').
            split.map(&:capitalize).join(' ')
        end
      end

      def split_tags(tag_set)
        tag_set.to_s.split(Aldrich::TAGGING_DELIMITER)
      end

      def split_images(image_url_set)
        image_url_set.to_s.split(Aldrich::TAGGING_DELIMITER)
      end
    end
  end
end
