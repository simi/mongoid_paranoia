# frozen_string_literal: true

module Mongoid
  module Paranoia
    class Configuration
      attr_accessor :paranoid_field
      attr_accessor :paranoid_flag

      def initialize
        @paranoid_field = :deleted_at
        @paranoid_flag  = :is_deleted
      end
    end
  end
end
