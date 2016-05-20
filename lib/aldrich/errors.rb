require "forwardable"

# Internal: This namespace contains all error objects specific entirely to the
# Importer service itself.
module Aldrich
  module Errors
    class ImportError < StandardError
      def initialize(message)
        super message
      end
    end

    class CannotInferModel < ImportError
      def initialize(group)
        message = "Model data does not match across all rows for #{group}"
        super message
      end
    end

    class ModelTransactionFailed < ImportError
      def initialize(product)
        message = "Transaction saving Model with group \"#{product.sku}\" failed"
        super message
      end
    end

    class InvalidImportMode < ImportError
      extend Forwardable

      attr_reader :import, :group

      def_delegator :import, :import?
      def_delegator :import, :update?

      def initialize(import, group)
        @import = import
        @group  = group
        super(message)
      end

      def message
        "Group code #{group} #{message_suffix}"
      end

      private

      def message_suffix
        if import?
          "already exists and cannot be updated during an import"
        elsif update?
          "does not exist and cannot be created during an update"
        end
      end
    end
  end
end
