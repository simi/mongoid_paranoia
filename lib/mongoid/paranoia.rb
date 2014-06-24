# encoding: utf-8
require 'mongoid/paranoia/monkey_patches'
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

    included do
      field :deleted_at, type: Time
      self.paranoid = true

      default_scope -> { where(deleted_at: nil) }
      scope :deleted, -> { ne(deleted_at: nil) }
      define_model_callbacks :restore
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
      run_callbacks(:destroy) { delete! }
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
    def remove_with_paranoia(options = {})
      cascade!
      time = self.deleted_at = Time.now
      paranoid_collection.find(atomic_selector).
        update({ "$set" => { paranoid_field => time }})
      @destroyed = true
      true
    end
    alias_method_chain :remove, :paranoia
    alias :delete :remove

    # Delete the paranoid +Document+ from the database completely.
    #
    # @example Hard delete the document.
    #   document.delete!
    #
    # @return [ true, false ] If the operation succeeded.
    #
    # @since 1.0.0
    def delete!
      remove_without_paranoia
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
    # TODO: @return [ Time ] The time the document had been deleted.
    #
    # @since 1.0.0
    def restore
      run_callbacks(:restore) do
        paranoid_collection.find(atomic_selector).
          update({ "$unset" => { paranoid_field => true }})
        attributes.delete("deleted_at")
        @destroyed = false
        true
      end
    end

    # Returns a string representing the documents's key suitable for use in URLs.
    def to_param
      new_record? ? nil : to_key.join('-')
    end

    def restore_associated
      # p "$$$$$$$$$$$$$$$$$$$$$$$"
      # p self.class
      # p self.class.methods.include?(:relations)
      # return unless self.class.methods.include?(:relations)

      # associations = self.class.relations.select do |key,value|
      #   value[:dependent] == :destroy
      # end 
      # p associations

      # associations.values.each do |association|
      #   assoc_data = self.send(association.name)
      #   unless assoc_data.nil?
      #     if assoc_data.paranoid?
      #       if assoc_data.is_a? Array
      #         assoc_data.deleted.each do |record|
      #           record.restore
      #         end
      #       else
      #         assoc_data.restore
      #       end
      #     end
      #   end
      # end
    end

    private

    # Get the collection to be used for paranoid operations.
    #
    # @example Get the paranoid collection.
    #   document.paranoid_collection
    #
    # @return [ Collection ] The root collection.
    #
    # @since 2.3.1
    def paranoid_collection
      embedded? ? _root.collection : self.collection
    end

    # Get the field to be used for paranoid operations.
    #
    # @example Get the paranoid field.
    #   document.paranoid_field
    #
    # @return [ String ] The deleted at field.
    #
    # @since 2.3.1
    def paranoid_field
      embedded? ? "#{atomic_position}.deleted_at" : "deleted_at"
    end

    
  end
end
