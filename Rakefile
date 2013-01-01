# Generated this engine with docs found here:
# http://nepalonrails.com/blog/2010/09/Creating-a-Rails-engine-with-tests-and-a-dummy-rails-application-embedded-in-it


require 'rubygems'
require 'bundler'
require "bundler/gem_tasks"

#begin
  #Bundler.setup(:default, :development)
#rescue Bundler::BundlerError => e
  #$stderr.puts e.message
  #$stderr.puts "Run `bundle install` to install missing gems"
  #exit e.status_code
#end
require 'rake'



require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rspec_opts = ['--color']
  spec.rcov_opts = ['--exclude', '^spec,/gems/,/\.bundler/']
end

task :default => :spec

#require 'rdoc/task'
#Rake::RDocTask.new do |rdoc|
#  version = File.exist?('VERSION') ? File.read('VERSION') : ""
#
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title = "phocoder-rails #{version}"
#  rdoc.rdoc_files.include('README*')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
