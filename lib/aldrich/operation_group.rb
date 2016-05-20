# Internal: This class is responsible for dispatching operation groups to
# OperationTranslator, but it is primarily responsible for capturing handled
# exceptional behavior raised internall during the import process. In each
# case, it will hand caught exceptions to the appropriate error handler.
module Aldrich
  class OperationGroup
    attr_reader :import, :operations

    # Public:  Simulates an import for given Operations, caching any
    # encountered errors.  Errors can be looked up with Importer.errors_for
    #
    # import     - An Import model object
    # operations - An Array of Importer::Operation objects
    #
    # Examples
    #
    #   Importer::OperationGroup.simulate!(import, operations)
    #   # => [ #<Product:0x746> ]
    #
    # Returns a flattened Array of a Product and all models associated with the
    # Product
    def self.simulate!(import, operations)
      new(import, operations).simulate!
    end

    # Public:  Performs an import for given Operations, caching any
    # encountered errors.  Errors can be looked up with Importer.errors_for
    #
    # import     - An Import model object
    # operations - An Array of Importer::Operation objects
    #
    # Examples
    #
    #   Importer::OperationGroup.import!(import, operations)
    #   # => [ #<Product:0x746> ]
    #
    # Returns a flattened Array of a Product and all models associated with the
    # Product
    def self.import!(import, operations)
      new(import, operations).import!
    end

    def initialize(import, operations)
      @import     = import
      @operations = operations
    end

    def simulate!
      Processors::ModelValidator.perform!(import.id, model)
    rescue Errors::InvalidImportMode => mode_exception
      cache_error(mode_exception)
    rescue Errors::CannotInferModel => inference_exception
      cache_error(inference_exception)
    rescue OpenURI::HTTPError => uri_error
      cache_error(uri_error)
    rescue Errno::ENOENT => file_error
      cache_error(file_error)
    end

    def import!
      Processors::ModelPersistor.perform!(import.id, model)
    rescue Errors::InvalidImportMode => mode_exception
      cache_error(mode_exception)
    rescue OpenURI::HTTPError => uri_error
      cache_error(uri_error)
    rescue Errno::ENOENT => file_error
      cache_error(file_error)
    rescue Errors::ModelTransactionFailed
    end

    def model
      # @model ||= OperationTranslator.product_and_associations(import, operations)
    end

    def group
      operations.first.group
    end

    private

    def cache_error(exception)
      ImporterErrorHandler.cache_importer_error(import, group, exception)
    end
  end
end
