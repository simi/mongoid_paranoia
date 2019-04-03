# encoding: utf-8
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
  end
end

Mongoid::Document.send(:include, Mongoid::Paranoia::Document)

module Mongoid
  module Association
    module Nested
      class Many
        # Destroy the child document, needs to do some checking for embedded
        # relations and delay the destroy in case parent validation fails.
        #
        # @api private
        #
        # @example Destroy the child.
        #   builder.destroy(parent, relation, doc)
        #
        # @param [ Document ] parent The parent document.
        # @param [ Proxy ] relation The relation proxy.
        # @param [ Document ] doc The doc to destroy.
        #
        # @since 3.0.10
        def destroy(parent, relation, doc)
          doc.flagged_for_destroy = true
          if !doc.embedded? || parent.new_record? || doc.paranoid?
            destroy_document(relation, doc)
          else
            parent.flagged_destroys.push(->{ destroy_document(relation, doc) })
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
