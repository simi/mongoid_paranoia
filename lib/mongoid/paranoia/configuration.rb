# frozen_string_literal: true

module Mongoid
  module Paranoia
    class Configuration
      attr_accessor :paranoid_field
      attr_accessor :paranoid_timestamp

      def initialize
        @paranoid_field = :is_deleted
        @paranoid_timestamp = :deleted_at
      end
    end
  end
end
