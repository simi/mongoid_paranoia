# encoding: utf-8
require 'mongoid/paranoia/monkey_patches'
require 'mongoid/paranoia/configuration'
require 'active_support'
require 'active_support/deprecation'

module Mongoid

  # Include this module to get soft deletion of root level documents.
  # This will add a deleted_at field to the +Document+, managed automatically.
  # Potentially incompatible with unique indices. (if collisions with deleted items)
  #
  # @example Make a document paranoid.
  #   class Person
  #     include Mongoid::Document
  #     include Mongoid::Paranoia
  #   end
  module Paranoia
    include Mongoid::Persistable::Deletable
    extend ActiveSupport::Concern

    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    # Allow the paranoid +Document+ to use an alternate field name for deleted_at.
    #
    # @example
    #   Mongoid::Paranoia.configure do |c|
    #     c.paranoid_field = :myFieldName
    #   end
    def self.configure
      yield(configuration)
    end

    included do
      field Paranoia.configuration.paranoid_field, as: :deleted_at, type: Time

      self.paranoid = true

      default_scope -> { where(deleted_at: nil) }
      scope :deleted, -> { ne(deleted_at: nil) }
      define_model_callbacks :restore
      define_model_callbacks :remove
    end

    # Delete the paranoid +Document+ from the database completely. This will
    # run the destroy callbacks.
    #
    # @example Hard destroy the document.
    #   document.destroy!
    #
    # @return [ true, false ] If the operation succeeded.
    #
    # @since 1.0.0
    def destroy!
      run_callbacks(:destroy) do
        run_callbacks(:remove) do
          delete!
        end
      end
    end

    # Override the persisted method to allow for the paranoia gem.
    # If a paranoid record is selected, then we only want to check
    # if it's a new record, not if it is "destroyed"
    #
    # @example
    #   document.persisted?
    #
    # @return [ true, false ] If the operation succeeded.
    #
    # @since 4.0.0
    def persisted?
      !new_record?
    end

    # Delete the +Document+, will set the deleted_at timestamp and not actually
    # delete it.
    #
    # @example Soft remove the document.
    #   document.remove
    #
    # @param [ Hash ] options The database options.
    #
    # @return [ true ] True.
    #
    # @since 1.0.0
    alias orig_remove :remove

    def remove(_ = {})
      return false unless catch(:abort) { apply_delete_dependencies! }
      time = self.deleted_at = Time.now
      _paranoia_update('$set' => { paranoid_field => time })
      @destroyed = true
      true
    end

    alias delete :remove

    # Delete the paranoid +Document+ from the database completely.
    #
    # @example Hard delete the document.
    #   document.delete!
    #
    # @return [ true, false ] If the operation succeeded.
    #
    # @since 1.0.0
    def delete!
      orig_remove
    end

    # Determines if this document is destroyed.
    #
    # @example Is the document destroyed?
    #   person.destroyed?
    #
    # @return [ true, false ] If the document is destroyed.
    #
    # @since 1.0.0
    def destroyed?
      (@destroyed ||= false) || !!deleted_at
    end
    alias :deleted? :destroyed?

    # Restores a previously soft-deleted document. Handles this by removing the
    # deleted_at flag.
    #
    # @example Restore the document from deleted state.
    #   document.restore
    #
    # For resoring associated documents use :recursive => true
    # @example Restore the associated documents from deleted state.
    #   document.restore(:recursive => true)
    #
    # TODO: @return [ Time ] The time the document had been deleted.
    #
    # @since 1.0.0
    def restore(opts = {})
      run_callbacks(:restore) do
        _paranoia_update("$unset" => { paranoid_field => true })
        attributes.delete("deleted_at")
        @destroyed = false
        restore_relations if opts[:recursive]
        true
      end
    end

    # Returns a string representing the documents's key suitable for use in URLs.
    def to_param
      new_record? ? nil : to_key.join('-')
    end

    def restore_relations
      self.relations.each_pair do |name, association|
        next unless association.dependent == :destroy
        relation = self.send(name)
        if relation.present? && relation.paranoid?
          Array.wrap(relation).each do |doc|
            doc.restore(:recursive => true)
          end
        end
      end
    end

    private

    # Get the collection to be used for paranoid operations.
    #
    # @example Get the paranoid collection.
    #   document.paranoid_collection
    #
    # @return [ Collection ] The root collection.
    def paranoid_collection
      embedded? ? _root.collection : self.collection
    end

    # Get the field to be used for paranoid operations.
    #
    # @example Get the paranoid field.
    #   document.paranoid_field
    #
    # @return [ String ] The deleted at field.
    def paranoid_field
      field = Paranoia.configuration.paranoid_field
      embedded? ? "#{atomic_position}.#{field}" : field
    end

    # @return [ Object ] Update result.
    #
    def _paranoia_update(value)
      paranoid_collection.find(atomic_selector).update_one(value)
    end
  end
end
