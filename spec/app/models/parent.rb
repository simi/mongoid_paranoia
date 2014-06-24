class Parent
	include Mongoid::Document
  include Mongoid::Paranoia
	field :name, type: String

	has_many :children, dependent: :destroy
end