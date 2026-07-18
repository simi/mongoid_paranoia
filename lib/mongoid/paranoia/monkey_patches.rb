# frozen_string_literal: true

module Mongoid
  module Paranoia
    module Document
      extend ActiveSupport::Concern

      included do
        # Indicates whether or not the document includes Mongoid::Paranoia.
        # In Mongoid 3, this method was defined on all Mongoid::Documents.
        # In Mongoid 4, it is no longer defined, hence we are shimming it here.
        class_attribute :paranoid
      end
    end

    # Skip paranoid docs flagged for destruction when checking whether a
    # candidate is already related, so they do not block a new sibling with
    # the same `==` key during a destroy-and-re-add nested attributes update.
    # Non-paranoid candidates fall through to stock Mongoid behavior via
    # `super`, so any future upstream fix is inherited automatically.
    module EmbedsManyProxyExtensions
      private

      # @example Check if a document is already related.
      #   relation.send(:object_already_related?, document)
      #
      # @param [ Document ] document The candidate document to check.
      #
      # @return [ true, false ] If a non-flagged sibling matches.
      def object_already_related?(document)
        return super unless document.paranoid?
        # rubocop:disable Style/CaseEquality -- matches upstream Mongoid's dedup check
        _target.any? {|existing| existing._id && !existing.flagged_for_destroy? && existing === document }
        # rubocop:enable Style/CaseEquality
      end
    end
  end
end

Mongoid::Document.include Mongoid::Paranoia::Document
Mongoid::Association::Embedded::EmbedsMany::Proxy.prepend(Mongoid::Paranoia::EmbedsManyProxyExtensions)

module Mongoid
  module Association
    module Embedded
      class EmbedsMany
        class Proxy < Association::Many
          # Delete the supplied document from the target. This method is proxied
          # in order to reindex the array after the operation occurs.
          #
          # @example Delete the document from the relation.
          #   person.addresses.delete(address)
          #
          # @param [ Document ] document The document to be deleted.
          #
          # @return [ Document, nil ] The deleted document or nil if nothing deleted.
          #
          # @since 2.0.0.rc.1
          def delete(document)
            execute_callback :before_remove, document
            doc = _target.delete_one(document)
            if doc && !_binding?
              _unscoped.delete_one(doc) unless doc.paranoid?
              if _assigning?
                if doc.paranoid?
                  doc.destroy(suppress: true)
                else
                  _base.add_atomic_pull(doc)
                end
              else
                doc.delete(suppress: true)
                unbind_one(doc)
              end
            end
            reindex
            execute_callback :after_remove, document
            doc
          end
        end
      end
    end
  end
end

module Mongoid
  module Association
    module Embedded
      class EmbedsMany
        class Proxy < Association::Many
          # For use only with Mongoid::Paranoia - will be removed in 4.0.
          #
          # @example Get the deleted documents from the relation.
          #   person.paranoid_phones.deleted
          #
          # @return [ Criteria ] The deleted documents.
          #
          # @since 3.0.10
          def deleted
            unscoped.deleted
          end
          # This class handles the behaviour for a document that embeds many other
          # documents within in it as an array.
        end
      end
    end
  end
end
