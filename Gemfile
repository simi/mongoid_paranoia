source 'https://rubygems.org'

case version = ENV['MONGOID_VERSION'] || '5'
when /^6/
  gem 'mongoid', git: 'git@github.com:mongodb/mongoid.git'
when /^5/
  gem 'mongoid', '~> 5.0'
when /^4/
  gem 'mongoid', '~> 4.0'
else
  gem 'mongoid', version
end

group :test do
  gem 'rspec', '~> 3.0.0'
end

group :development do
  gem 'rake'
end

# remove :name arg when migration to '_' gem name is complete
gemspec name: 'mongoid_paranoia'
