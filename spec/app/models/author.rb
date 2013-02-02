class Author
  include Mongoid::Document
  field :name, type: String

  belongs_to :post, class_name: "ParanoidPost"
end
