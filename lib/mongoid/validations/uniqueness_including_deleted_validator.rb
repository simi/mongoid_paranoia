# encoding: utf-8
module Mongoid
  module Validations
    # Validates whether or not a field is unique against the documents in the
    # database including deleted documents for paranoic models.
    #
    # @example Define the uniqueness validator.
    #
    #   class Person
    #     include Mongoid::Document
    #     include Mongoid::Paranoia
    #     field :title
    #
    #     validates :title, :uniqueness_including_deleted => true
    #   end
    class UniquenessIncludingDeletedValidator < Mongoid::Validations::UniquenessValidator
      # Scope the criteria to the scope options provided.
      # Added Paranoia spice.
      #
      # @api private
      #
      # @example Scope the criteria.
      #   validator.scope(criteria, document)
      #
      # @param [ Criteria ] criteria The criteria to scope.
      # @param [ Document ] document The document being validated.
      #
      # @return [ Criteria ] The scoped criteria.
      #
      # @since 4.0.0
      def scope(criteria, document, attribute)
        criteria = super
        criteria = criteria.where(deleted_at: nil) if document.respond_to?(:paranoid)
        criteria
      end
    end
  end
end
