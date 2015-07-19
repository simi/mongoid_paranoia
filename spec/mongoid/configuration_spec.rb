require "spec_helper"

module Mongoid
  module Paranoia
    describe Configuration do
      describe '#paranoid_field' do
        it 'initializes with default value set to :deleted_at' do
          expect(Configuration.new.paranoid_field).to eq(:deleted_at)
        end

        it 'can be updated' do
          config = Configuration.new
          config.paranoid_field = :myFieldName
          expect(config.paranoid_field).to eq(:myFieldName)
        end
      end
    end
  end
end
