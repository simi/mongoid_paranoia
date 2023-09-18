# frozen_string_literal: true

require 'bundler/setup'
require 'mongoid'
require 'mongoid/paranoia'
require 'benchmark'

Mongoid.configure do |config|
  config.connect_to('my_little_test')
end

class Model
  include Mongoid::Document
  field :text, type: String

  index({ text: 'text' })
end

class ParanoidModel
  include Mongoid::Document
  include Mongoid::Paranoia
  field :text, type: String

  index({ text: 'text' })
end

class MetaParanoidModel
  include Mongoid::Document
  field :text, type: String
  field :deleted_at, type: Time
  default_scope -> { where(deleted_at: nil) }

  index({ text: 'text' })
end

if ENV['FORCE']
  Mongoid.purge!
  Mongoid::Tasks::Database.create_indexes

  n = 50_000
  n.times {|i| Model.create(text: "text #{i}") }
  n.times {|i| ParanoidModel.create(text: "text #{i}") }
  n.times {|i| MetaParanoidModel.create(text: "text #{i}") }
end

n = 100

puts 'text_search benchmark ***'
Benchmark.bm(20) do |x|
  x.report('without') { n.times { Model.text_search('text').execute } }
  x.report('with')    { n.times { ParanoidModel.text_search('text').execute } }
  x.report('meta')    { n.times { MetaParanoidModel.text_search('text').execute } }
  x.report('unscoped meta') { n.times { MetaParanoidModel.unscoped.text_search('text').execute } }
  x.report('unscoped paranoid') { n.times { ParanoidModel.unscoped.text_search('text').execute } }
end

puts ''
puts 'Pluck all ids benchmark ***'
Benchmark.bm(20) do |x|
  x.report('without') { n.times { Model.all.pluck(:id) } }
  x.report('with')    { n.times { ParanoidModel.all.pluck(:id) } }
  x.report('meta')    { n.times { MetaParanoidModel.all.pluck(:id) } }
  x.report('unscoped meta') { n.times { MetaParanoidModel.unscoped.all.pluck(:id) } }
  x.report('unscoped paranoid') { n.times { ParanoidModel.unscoped.all.pluck(:id) } }
end
