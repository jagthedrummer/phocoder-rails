# Load the rails application
require File.expand_path('../application', __FILE__)

Spawn::default_options({ :method => :thread })

# Initialize the rails application
Dummy::Application.initialize!
