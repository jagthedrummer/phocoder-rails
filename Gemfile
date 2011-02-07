source "http://rubygems.org"
      
gem "rails", "3.0.0"
gem "capybara", ">= 0.3.9"
gem "webrat"


gem "sqlite3-ruby", :require => "sqlite3"

#developing against postgres for now since I have an old version of SQLite3
#gem 'pg'


if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end
 
gem "rspec", "~> 2.1.0"
gem "rspec-rails", ">= 2.0.0.beta"
 
group :development do
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.5.1"
  gem "rcov", ">= 0"
end

group :test do
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.5.1"
  gem "rcov", ">= 0"
  gem 'autotest', '4.4.4'
  gem 'redgreen', '1.2.2'
end
