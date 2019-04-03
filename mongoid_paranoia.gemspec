# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid/paranoia/version'

Gem::Specification.new do |gem|
  gem.name          = 'mongoid_paranoia'
  gem.version       = Mongoid::Paranoia::VERSION
  gem.authors       = ['Durran Jordan', 'Josef Šimánek']
  gem.email         = ['durran@gmail.com', 'retro@ballgag.cz']
  gem.description   = %q{There may be times when you don't want documents to actually get deleted from the database, but "flagged" as deleted. Mongoid provides a Paranoia module to give you just that.}
  gem.summary       = %q{Paranoid documents}
  gem.homepage      = 'https://github.com/simi/mongoid-paranoia'
  gem.license       = 'MIT'

  gem.files         = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  gem.test_files    = Dir.glob('{perf,spec}/**/*')
  gem.require_paths = ['lib']

  gem.add_dependency 'mongoid', '~> 7.0'
end
