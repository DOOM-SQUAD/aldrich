# Internal: This class is concerned with exceptions specific to the Importer
# service, as opposed to ActiveRecord error objects pull from models.
module Aldrich
  class ImporterErrorHandler
    attr_reader :import, :group, :exception

    # Public: Sends a StandardError object to the cache for later retrival by
    # users.
    #
    # import    - An Import model object
    # group     - A String representing the group of operations that raised the
    #             exception
    # exception - A StandardError object
    #
    # Examples
    #
    #   Importer::ImportErrorHandler.cache_importer_error(
    #     import, group, exception
    #   )
    #   # => #<Importer::Decorators::CachedError:0x44356>
    #
    # Returns an instance of an Importer::Decorators::CachedError
    def self.cache_importer_error(import, group, exception)
      new(import, group, exception).cache!
    end

    def initialize(import, group, exception)
      @import    = import
      @group     = group
      @exception = exception
    end

    def cache!
      CasualJacket.add_error(import.id, error_object)
    end

    def error_object
      Decorators::CachedError.new(import.id, group, exception.class.to_s, exception.message)
    end
  end
end
