# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"


ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
# don't know enough about capybara now. 
# might bring this back later.
#require "capybara/rails"
#Capybara.default_driver   = :rack_test
#Capybara.default_selector = :css


# Run any available migration
# need to move this into a before block
# ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  
  #run only the debug tests
  #config.filter_run :debug => true
  
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers
  
  # == Mock Framework
  config.mock_with :rspec

  config.fixture_path = "#{File.dirname(__FILE__)}/fixtures"
  
  config.before(:all){
    
    #change this if sqlite is unavailable
    dbconfig = {
      :adapter => 'sqlite3',
      :database => ':memory:'
    }
    
    ::ActiveRecord::Base.establish_connection(dbconfig)
    ::ActiveRecord::Migration.verbose = false
    
    ::ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
  }
  
  config.after(:all){
    ::ActiveRecord::Migrator.down File.expand_path("../dummy/db/migrate/", __FILE__)
  }
end

