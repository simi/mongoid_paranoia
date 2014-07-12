class NormBase
  include Mongoid::Document

  has_one  :norm_has_one, dependent: :destroy
  has_one  :para_has_one, dependent: :destroy

  has_many :norm_has_many, dependent: :destroy
  has_many :para_has_many, dependent: :destroy

  has_many :norm_has_many_poly, dependent: :destroy
  has_many :para_has_many_poly, dependent: :destroy

  belongs_to :norm_belongs_to_one, dependent: :destroy
  belongs_to :para_belongs_to_one, dependent: :destroy

  belongs_to :norm_belongs_to, dependent: :destroy
  belongs_to :para_belongs_to, dependent: :destroy

  has_and_belongs_to_many :norm_habtm, dependent: :destroy
  has_and_belongs_to_many :para_habtm, dependent: :destroy

  embeds_one  :norm_embeds_one
  embeds_one  :para_embeds_one

  embeds_many :norm_embeds_many
  embeds_many :para_embeds_many

  embeds_many :norm_embeds_many_poly
  embeds_many :para_embeds_many_poly
end

class ParaBase
  include Mongoid::Document
  include Mongoid::Paranoia

  has_one  :norm_has_one, dependent: :destroy
  has_one  :para_has_one, dependent: :destroy

  has_many :norm_has_many, dependent: :destroy
  has_many :para_has_many, dependent: :destroy

  has_many :norm_has_many_poly, dependent: :destroy
  has_many :para_has_many_poly, dependent: :destroy

  belongs_to :norm_belongs_to_one, dependent: :destroy
  belongs_to :para_belongs_to_one, dependent: :destroy

  belongs_to :norm_belongs_to, dependent: :destroy
  belongs_to :para_belongs_to, dependent: :destroy

  has_and_belongs_to_many :norm_habtm, dependent: :destroy
  has_and_belongs_to_many :para_habtm, dependent: :destroy

  embeds_one  :norm_embeds_one
  embeds_one  :para_embeds_one

  embeds_many :norm_embeds_many
  embeds_many :para_embeds_many

  embeds_many :norm_embeds_many_poly
  embeds_many :para_embeds_many_poly
end

class NormHasOne
  include Mongoid::Document

  belongs_to :norm_base
  belongs_to :para_base

  has_one :norm_belongs_to, dependent: :destroy
  has_one :para_belongs_to, dependent: :destroy

  has_one :norm_habtm, dependent: :destroy
  has_one :norm_habtm, dependent: :destroy
end

class NormHasMany
  include Mongoid::Document

  belongs_to :norm_base
  belongs_to :para_base

  has_many :norm_belongs_to, dependent: :destroy
  has_many :para_belongs_to, dependent: :destroy

  has_many :norm_habtm, dependent: :destroy
  has_many :norm_habtm, dependent: :destroy
end

class NormHasManyPoly
  include Mongoid::Document

  belongs_to :base, polymorphic: true
end

class NormBelongsToOne
  include Mongoid::Document

  has_one :norm_base
  has_one :para_base
end

class NormBelongsTo
  include Mongoid::Document

  has_many :norm_base
  has_many :para_base

  belongs_to :norm_has_one, dependent: :destroy
  belongs_to :para_has_one, dependent: :destroy

  belongs_to :norm_has_many, dependent: :destroy
  belongs_to :para_has_many, dependent: :destroy
end

class NormHabtm
  include Mongoid::Document

  has_and_belongs_to_many :norm_base
  has_and_belongs_to_many :para_base

  belongs_to :norm_has_one, dependent: :destroy
  belongs_to :para_has_one, dependent: :destroy

  belongs_to :norm_has_many, dependent: :destroy
  belongs_to :para_has_many, dependent: :destroy

  has_and_belongs_to_many :recursive, class_name: 'NormHabtm', inverse_of: :recursive, dependent: :destroy
  has_and_belongs_to_many :para_habtm, dependent: :destroy
end

class NormEmbedsOne
  include Mongoid::Document

  embedded_in :norm_base
  embedded_in :para_base
end

class NormEmbedsMany
  include Mongoid::Document

  embedded_in :norm_base
  embedded_in :para_base
end

class NormEmbedsManyPoly
  include Mongoid::Document

  embedded_in :base, polymorphic: true
end

class ParaHasOne
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :norm_base
  belongs_to :para_base

  has_one :norm_belongs_to, dependent: :destroy
  has_one :para_belongs_to, dependent: :destroy

  has_one :norm_habtm, dependent: :destroy
  has_one :norm_habtm, dependent: :destroy
end

class ParaHasMany
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :norm_base
  belongs_to :para_base

  has_many :norm_belongs_to, dependent: :destroy
  has_many :para_belongs_to, dependent: :destroy

  has_many :norm_habtm, dependent: :destroy
  has_many :norm_habtm, dependent: :destroy
end

class ParaHasManyPoly
  include Mongoid::Document
  include Mongoid::Paranoia

  belongs_to :base, polymorphic: true
end

class ParaBelongsToOne
  include Mongoid::Document
  include Mongoid::Paranoia

  has_one :norm_base
  has_one :para_base
end

class ParaBelongsTo
  include Mongoid::Document
  include Mongoid::Paranoia

  has_many :norm_base
  has_many :para_base

  belongs_to :norm_has_one, dependent: :destroy
  belongs_to :para_has_one, dependent: :destroy

  belongs_to :norm_has_many, dependent: :destroy
  belongs_to :para_has_many, dependent: :destroy
end

class ParaHabtm
  include Mongoid::Document
  include Mongoid::Paranoia

  has_and_belongs_to_many :norm_base
  has_and_belongs_to_many :para_base

  belongs_to :norm_has_one, dependent: :destroy
  belongs_to :para_has_one, dependent: :destroy

  belongs_to :norm_has_many, dependent: :destroy
  belongs_to :para_has_many, dependent: :destroy

  has_and_belongs_to_many :norm_habtm, dependent: :destroy
  has_and_belongs_to_many :recursive, class_name: 'ParaHabtm', inverse_of: :recursive, dependent: :destroy
end

class ParaEmbedsOne
  include Mongoid::Document
  include Mongoid::Paranoia

  embedded_in :norm_base
  embedded_in :para_base
end

class ParaEmbedsMany
  include Mongoid::Document
  include Mongoid::Paranoia

  embedded_in :norm_base
  embedded_in :para_base
end

class ParaEmbedsManyPoly
  include Mongoid::Document
  include Mongoid::Paranoia

  embedded_in :base, polymorphic: true
end
