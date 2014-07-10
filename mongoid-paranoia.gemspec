# -*- encoding: utf-8 -*-

# This is a legacy gemspec intended to facilitate migration from the old
# mongoid-paranoia name to the new mongoid_paranoia name. We can delete
# this file around October 2014

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

  gem.post_install_message = %Q(
    This repo has moved to `mongoid_paranoia` (with an underscore). Please use our
    officially released gem with this name. Note that `mongoid-paranoia` (hyphenated)
    is a different gem/repo whose owner is not accepting enhancements.
  )

  gem.add_dependency "mongoid", '> 3'
end
