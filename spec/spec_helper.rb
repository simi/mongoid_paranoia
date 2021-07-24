$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongoid'
require 'mongoid/paranoia'
require 'rspec'

# When testing locally we use the database named mongoid_test. However when
# tests are running in parallel on Travis we need to use different database
# names for each process running since we do not have transactions and want a
# clean slate before each spec run.
def database_id
  'mongoid_paranoia_test'
end

# Set the database that the spec suite connects to.
Mongoid.configure do |config|
  config.belongs_to_required_by_default = false
  config.connect_to(database_id)
end

RSpec.configure do |config|

  # Drop all collections
  config.before(:each) do
    Mongoid.purge!
  end

  config.before(:all) do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO
  end

  config.after(:all) do
    Mongoid.purge!
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular('address_components', 'address_component')
end

Dir[File.join(File.dirname(__FILE__), 'app/models/*.rb')].each{ |f| require f }
