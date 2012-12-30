source "http://rubygems.org"
      
gem "rails", ">=3.0.0"



#puts "phocoder-rails : RUBY_VERSION = #{RUBY_VERSION}"
#puts RUBY_VERSION < '1.9'

#

#developing against postgres for now since I have an old version of SQLite3
#gem 'pg'

gem 'phocoder-rb'
gem 'zencoder'
gem "mimetype-fu", "~> 0.1.2", :require => 'mimetype_fu'
gem 'aws-s3', :require => 'aws/s3'
#gem "spawn", :git => "git://github.com/jagthedrummer/spawn.git"
gem "spawn", :git => 'git://github.com/tra/spawn', :branch => "edge"
#if RUBY_VERSION < '1.9'
#  gem "ruby-debug", ">= 0.10.3"
#end
 
#gem "rspec", "~> 2.1.0"
#gem "rspec-rails", ">= 2.0.0.beta"

gem 'simplecov', :require => false, :group => :test
 
group :development do
  gem 'rspec-rails', '2.4.1'
  gem "bundler"
  gem "jeweler"
  #gem "rcov", ">= 0"
end

group :test do
  gem "webrat"    
  gem "capybara", ">= 0.3.9"    
  gem "sqlite3-ruby", :require => "sqlite3"
  gem 'rspec', '2.4.0'
  gem 'rspec-rails', '2.4.1'
  gem "bundler"
  gem "jeweler"
  #gem "rcov", ">= 0"
  gem 'autotest', '4.4.4'
  gem 'redgreen', '1.2.2'
  gem "webmock"
end
