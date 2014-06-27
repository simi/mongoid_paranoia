class Child
  include Mongoid::Document
  include Mongoid::Paranoia

  field :name, type: String
  belongs_to :parent
end
