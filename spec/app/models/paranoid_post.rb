class ParanoidPost
  include Mongoid::Document
  include Mongoid::Paranoia

  field :title, type: String

  attr_accessor :after_destroy_called, :before_destroy_called,
                :after_restore_called, :before_restore_called,
                :after_remove_called, :before_remove_called,
                :around_before_restore_called, :around_after_restore_called

  belongs_to :person

  has_and_belongs_to_many :tags
  has_many :authors, dependent: :delete_all, inverse_of: :post
  has_many :titles, dependent: :restrict_with_error

  scope :recent, -> {where(created_at: { "$lt" => Time.now, "$gt" => 30.days.ago })}

  before_destroy :before_destroy_stub
  after_destroy  :after_destroy_stub

  before_remove :before_remove_stub
  after_remove  :after_remove_stub

  before_restore :before_restore_stub
  after_restore  :after_restore_stub
  around_restore :around_restore_stub

  def before_destroy_stub
    self.before_destroy_called = true
  end

  def after_destroy_stub
    self.after_destroy_called = true
  end

  def before_remove_stub
    self.before_remove_called = true
  end

  def after_remove_stub
    self.after_remove_called = true
  end

  def before_restore_stub
    self.before_restore_called = true
  end

  def after_restore_stub
    self.after_restore_called = true
  end

  def around_restore_stub
    self.around_before_restore_called = true
    yield
    self.around_after_restore_called = true
  end

  class << self
    def old
      where(created_at: { "$lt" => 30.days.ago })
    end
  end
end
