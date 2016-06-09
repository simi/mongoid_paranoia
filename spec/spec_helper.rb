$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "mongoid"
require "mongoid/paranoia"
require "rspec"

# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MONGOID_SPEC_HOST"] ||= "localhost"
ENV["MONGOID_SPEC_PORT"] ||= "27017"

# These are used when creating any connection in the test suite.
HOST = ENV["MONGOID_SPEC_HOST"]
PORT = ENV["MONGOID_SPEC_PORT"].to_i

# Moped.logger.level = Logger::DEBUG
# Mongoid.logger.level = Logger::DEBUG

# When testing locally we use the database named mongoid_test. However when
# tests are running in parallel on Travis we need to use different database
# names for each process running since we do not have transactions and want a
# clean slate before each spec run.
def database_id
  "mongoid_test"
end

# Can we connect to MongoHQ from this box?
def mongohq_connectable?
  ENV["MONGOHQ_REPL_PASS"].present?
end

# Set the database that the spec suite connects to.
Mongoid.configure do |config|
  config.belongs_to_required_by_default = false
  config.connect_to(database_id)
end

module Rails
  class Application
  end
end

module MyApp
  class Application < Rails::Application
  end
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

  # Filter out MongoHQ specs if we can't connect to it.
  config.filter_run_excluding(config: ->(value){
    return true if value == :mongohq && !mongohq_connectable?
  })
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular("address_components", "address_component")
end

Dir[File.join(File.dirname(__FILE__), "app/models/*.rb")].each{ |f| require f }
