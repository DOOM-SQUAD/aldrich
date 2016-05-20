# Internal: This class decorated CasualJacket::CachedError only in the
# context of cration. Other instances that interact with cached errors will
# use the base object from CasualJacket
module Aldrich
  module Decorators
    class CachedError < CasualJacket::CachedError

      attr_reader :field, :message

      # Public: Initializes a CachedError
      #
      # handle  - A String or Fixnum representing an Import id or handle
      # group   - A String representing the operation group in which the error
      #           occured
      # field   - A String representing the field on which the error occured
      # message - A String representing the error message
      def initialize(handle, group, field, message)
        @field   = field
        @message = message
        super(handle, build_context, group)
      end

      private

      def build_context
        { field => message }
      end
    end
  end
end
