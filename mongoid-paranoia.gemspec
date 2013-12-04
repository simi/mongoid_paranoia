# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "mongoid-paranoia"
  gem.version       = "0.1"
  gem.authors       = ["Durran Jordan", "Josef Šimánek"]
  gem.email         = ["durran@gmail.com", "retro@ballgag.cz"]
  gem.description   = %q{There may be times when you don't want documents to actually get deleted from the database, but "flagged" as deleted. Mongoid provides a Paranoia module to give you just that.}
  gem.summary       = %q{Paranoid documents}
  gem.homepage      = "https://github.com/simi/mongoid-paranoia"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activemodel", ['~> 4.0.0']
  gem.add_dependency "mongoid", '> 3'
  gem.add_development_dependency "rspec", '~> 2.11'
end
