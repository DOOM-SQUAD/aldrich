module Aldrich
  module Factories
    class TaggingLegend
      attr_reader :tagging_headers

      def self.translated_tags(tagging_headers)
        new(tagging_headers).translated_tags
      end

      def initialize(tagging_headers)
        @tagging_headers = tagging_headers
      end

      def translated_tags
        all_tag_headers.delete_if do |header, values|
          header.nil? || header.strip.empty?
        end
      end

      private

      def all_tag_headers
        {
          replacement_header => [Aldrich::TAGGING_REPLACE],
          addition_header    => [Aldrich::TAGGING_APPEND],
          deletion_header    => [Aldrich::TAGGING_DELETE],
        }
      end

      def replacement_header
        tagging_headers.fetch('replacements', '').chomp
      end

      def addition_header
        tagging_headers.fetch('additions', '').chomp
      end

      def deletion_header
        tagging_headers.fetch('deletions', '').chomp
      end
    end
  end
end
