# frozen_string_literal: true

source 'https://rubygems.org'
gemspec name: 'mongoid_paranoia'

case (version = ENV['MONGOID_VERSION'] || '8')
when /\Ahead\z/i
  gem 'mongoid', github: 'mongodb/mongoid'
when /\A\d+\z/
  gem 'mongoid', "~> #{version}.0"
else
  gem 'mongoid', version
end

gem 'rake'
gem 'rspec'
gem 'rubocop'
