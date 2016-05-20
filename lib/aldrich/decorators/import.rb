# Public: This class is used to decorate an import for any interaction with
# views or programatically consumed content. It provides convenient access
# to directly related data and human formatted strings for readability
module Aldrich
  module Decorators
    class Import
      def initialize(import)
        @import = import
      end

      def human_date
        created_at.strftime("%m-%d-%Y %I:%M %p")
      end

      def human_job_type
        job_type.to_s.titleize
      end

      def user_email
        user.email if user.present?
      end

      def vendor_name
        vendor.name if vendor.present?
      end

      def status
        state_machine.state.titleize
      end

      def fresh?
        state_machine.fresh?
      end

      def ready?
        state_machine.ready?
      end

      def file_name
        File.basename(import.spreadsheet.file.path)
      end

      def legend_present?
        group_header.present? || legend.present?
      end

      def human_legend(&block)
        yield group_header, "Group Code"
        sorted_headers.each do |header|
          yield header, human_field_list(header) if block_given?
        end
      end

      private

      def state_machine
        Processors::Import.new(import)
      end

      def sorted_headers
        legend.keys.sort
      end

      def human_field_list(header)
        titleized_fields(header).join(', ')
      end

      def titleized_fields(header)
        legend[header].map do |field|
          field.titleize
        end
      end
    end
  end
end
