require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'forwardable'
require 'open-uri'
require 'casual_jacket'

require_relative 'aldrich/util'

require_relative 'aldrich/decorators/cached_error'
require_relative 'aldrich/decorators/import'
require_relative 'aldrich/decorators/operation'

require_relative 'aldrich/factories/attribute_legend'
require_relative 'aldrich/factories/field_legend'
require_relative 'aldrich/factories/tagging_legend'

require_relative 'aldrich/models/import'

require_relative 'aldrich/model_tools/detector'

require_relative 'aldrich/processors/model_validator'
require_relative 'aldrich/processors/model_persistor'

require_relative 'aldrich/errors'
require_relative 'aldrich/importer_error_handler'
require_relative 'aldrich/operation_group'
require_relative 'aldrich/sanitizer'
require_relative 'aldrich/squeezer'

# Public: Top-level API namespace through which all service interaction is 
# intended to occur. If a a needed interface or piece of functionality is not
# present, it is probably indicative of a feature need for the system as a
# whole.
module Aldrich
  # NOTE (JamesChristie+cmhobbs) for use until CatalogService is a thing.
  #      Rejigger the service to behave appropriately when that time comes.
  ATTRIBUTE_NAME_POSTFIX = "_attribute_name"
  ATTRIBUTE_CODE_POSTFIX = "_attribute_code"

  TAGGING_REPLACE = "tagging_replace"
  TAGGING_APPEND  = "tagging_append"
  TAGGING_DELETE  = "tagging_delete"

  TAGGING_DELIMITER = "|"

  IMAGE_URLS = "image_urls"

  extend self

  # Public: Lists the available fields that are mutable for sellable items
  #
  # Returns a Hash on Symbol keys representing mutable fields with Symbol
  # values stipulating the translator type to be used for the field
  def available_item_fields
    FieldAccess.available_item_fields
  end

  # Public: Allows iteration of the canonical operations for a given Import
  #
  # import - An Import model object
  # block  - The block to which each valid operation is yielded
  #
  # Returns a hash of CasualJacket::Operation objects grouped by group stings
  def canonical_operations_for(import, &block)
    each_operation_group(import.id) do |operations|
      begin
        AssociationTools::OperationGroupValidator.ensure_matching_product_data(operations)
        yield operations.first if block_given?
      rescue Errors::CannotInferProduct
      end
    end
  end

  # Public: Adds an error to a given import's list of errors in the cache
  #
  # import    - An Import model object
  # group     - A String representing a product group
  # exception - A StandardError object
  def add_error(import, group, exception)
    ImporterErrorHandler.cache_importer_error(import, group, exception)
  end

  # Public: Verify that a given import is valid and error free.
  #
  # import - An Import model object
  #
  # Examples
  #
  #   import = Import.find(42)
  #   Importer.clean_import?(import)
  #   # => true
  #
  # Returns a boolean value.
  def clean_import?(import)
    CasualJacket.list_errors(import.id).empty?
  end

  # Public: Return any cached errors present for a given import.
  #
  # import - An Import model object
  #
  # Examples
  #
  #   import = Import.find(42)
  #   Importer.errors_for(import)
  #   # => [ #<CasualJacket::Error:0x1337> ]
  #
  # Returns an Array of CasualJacket::Error objects.
  def errors_for(import)
    CasualJacket.list_errors(import.id)
  end

  # Public: Send CSV data from a given Import to the cache for freeze-drying.
  #
  # import - An Import model object
  #
  # Examples
  #
  #   import = Import.find(42)
  #   Importer.cache_spreadsheet(import)
  #   # => 'OK'
  #
  # Returns a Redis success or failure string.
  def cache_spreadsheet(import)
    CasualJacket.cache_operations(
      import.id,
      import.spreadsheet_contents,
      import.legend,
      import.group_header
    )
  end

  # Public:  Simulates an import for all Operations associated with an Import,
  # caching any encountered errors.  Errors can be looked up with .errors_for
  #
  # import - An Import model object
  #
  # Examples
  #
  #   import = Import.find(42)
  #   Importer.perform_simulation(import)
  #   # => { "group" => [ "test-import:operation:group:1234" ] }
  #
  # Returns a hash of Operation groups and their child keys.
  def perform_simulation(import)
    clear_errors(import)
    each_operation_group(import.id) do |operations|
      OperationGroup.simulate!(import, operations)
    end
  end

  # Public: Performs an import.  This will create Products and their
  # associations, caching any encountered errors.
  #
  # import - An Import model object
  #
  # Examples
  #
  #   import = Import.find(42)
  #   Importer.perform_import(import)
  #   # => { "group" => [ "test-import:operation:group:1234" ] }
  #
  # Returns a hash of Operation groups and their child keys.
  def perform_import(import)
    clear_errors(import)
    each_operation_group(import.id) do |operations|
      OperationGroup.import!(import, operations)
    end
  end

  private

  def clear_errors(import)
    CasualJacket.clear_errors(import.id)
  end

  def each_operation_group(id, &block)
    CasualJacket.each_operation_group(id) do |operations|
      yield operations.map { |op| ::Importer::Decorators::Operation.new(op) }
    end
  end
end
