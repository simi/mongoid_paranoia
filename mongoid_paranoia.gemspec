# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'mongoid/paranoia/version'

Gem::Specification.new do |gem|
  gem.name          = 'mongoid_paranoia'
  gem.version       = Mongoid::Paranoia::VERSION
  gem.authors       = ['Durran Jordan', 'Josef Šimánek']
  gem.email         = ['durran@gmail.com', 'retro@ballgag.cz']
  gem.description   = 'Provides a Paranoia module documents which soft-deletes documents.'
  gem.summary       = 'Paranoid documents'
  gem.homepage      = 'https://github.com/simi/mongoid-paranoia'
  gem.license       = 'MIT'

  gem.files         = Dir.glob('lib/**/*') + %w[LICENSE README.md]
  gem.test_files    = Dir.glob('{perf,spec}/**/*')
  gem.require_paths = ['lib']

  gem.add_dependency 'mongoid', '~> 7.0'

  gem.add_development_dependency 'rubocop', '>= 1.8.1'
end
