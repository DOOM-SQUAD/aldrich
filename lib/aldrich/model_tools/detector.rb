module Aldrich
  module ModelTools
    # Internal: This class is responsible for finding any existing, matching
    # instance of a model for given criteria within a given ActiveRecord
    # association set
    class Detector
      attr_reader :model_set, :criteria

      # Public: Locates an ActiveRecord model inside the given association set
      #         that matches the given criteria
      #
      # model_set - An Enumerable set of ActiveRecord model instances
      # criteria  - A Hash representing idempotent attribute criteria
      #
      # Returns an ActiveRecord model instance or nil
      def self.instance_for(model_set, criteria)
        new(model_set, criteria).detect_model
      end

      def initialize(model_set, criteria)
        @model_set = model_set
        @criteria  = criteria
      end

      def detect_model
        model_set.detect { |model| matching_model?(model) }
      end

      private

      def fields
        criteria.keys
      end

      def matching_model?(model)
        fields.any? do |field|
          model_value(field, model) == criteria_value(field)
        end
      end

      def model_value(field, model)
        model.public_send("#{field}")
      end

      def criteria_value(field)
        criteria.fetch(field)
      end
    end
  end
end
