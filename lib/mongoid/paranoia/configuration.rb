# frozen_string_literal: true

module Mongoid
  module Paranoia
    class Configuration
      attr_accessor :paranoid_field

      def initialize
        @paranoid_field = :deleted_at
      end
    end
  end
end
