# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phocoder_rails/version'

Gem::Specification.new do |gem|
  gem.name          = "phocoder-rails"
  gem.version       = PhocoderRails::VERSION
  gem.authors       = ["Jeremy Green"]
  gem.email         = ["jeremy@octolabs.com"]
  gem.description   = %q{Rails engine for easy integration with phocoder.com}
  gem.summary       = %q{Rails engine for easy integration with phocoder.com}
  gem.homepage      = "http://www.phocoder.com/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rails", ">= 3.0.0"
  gem.add_dependency 'phocoder-rb'
  gem.add_dependency 'zencoder'
  gem.add_dependency "mimetype-fu", "~> 0.1.2"#, :require => 'mimetype_fu'
  gem.add_dependency 'aws-s3'#, :require => 'aws/s3'
  gem.add_dependency "spawn"#, :git => 'git://github.com/tra/spawn', :branch => "edge"

  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency 'rspec-rails', '2.4.1'
  gem.add_development_dependency "webrat"
  gem.add_development_dependency "capybara", ">= 0.3.9"
  gem.add_development_dependency "sqlite3-ruby"#, :require => "sqlite3"
  gem.add_development_dependency 'rspec', '2.4.0'
  gem.add_development_dependency 'rspec-rails', '2.4.1'
  gem.add_development_dependency 'autotest', '4.4.4'
  gem.add_development_dependency 'redgreen', '1.2.2'
  gem.add_development_dependency "webmock"
  gem.add_development_dependency 'simplecov'
end

