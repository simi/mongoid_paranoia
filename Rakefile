# frozen_string_literal: true

require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'rake'

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

RSpec::Core::RakeTask.new('spec') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task default: :spec
