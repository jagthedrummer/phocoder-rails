# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{phocoder-rails}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Green"]
  s.date = %q{2011-02-09}
  s.description = %q{Rails engine for easy integration with phocoder.com}
  s.email = %q{jagthedrummer@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".autotest",
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "app/controllers/phocoder_controller.rb",
    "app/helpers/phocoder_helper.rb",
    "app/views/phocoder/_thumbnail_update.html.erb",
    "app/views/phocoder/thumbnail_update.js.rjs",
    "config/routes.rb",
    "lib/phocoder_rails.rb",
    "lib/phocoder_rails/acts_as_phocodable.rb",
    "lib/phocoder_rails/engine.rb",
    "phocoder-rails.gemspec",
    "spec/controllers/phocoder_controller_spec.rb",
    "spec/dummy/Rakefile",
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/models/image_upload.rb",
    "spec/dummy/app/views/layouts/application.html.erb",
    "spec/dummy/config.ru",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/database.yml",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/secret_token.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/locales/en.yml",
    "spec/dummy/config/routes.rb",
    "spec/dummy/db/migrate/001_create_image_uploads.rb",
    "spec/dummy/public/404.html",
    "spec/dummy/public/422.html",
    "spec/dummy/public/500.html",
    "spec/dummy/public/favicon.ico",
    "spec/dummy/public/index.html",
    "spec/dummy/public/javascripts/application.js",
    "spec/dummy/public/javascripts/controls.js",
    "spec/dummy/public/javascripts/dragdrop.js",
    "spec/dummy/public/javascripts/effects.js",
    "spec/dummy/public/javascripts/prototype.js",
    "spec/dummy/public/javascripts/rails.js",
    "spec/dummy/public/stylesheets/.gitkeep",
    "spec/dummy/script/rails",
    "spec/engine_spec.rb",
    "spec/fixtures/big_eye_tiny.jpg",
    "spec/helpers/phocoder_helper_spec.rb",
    "spec/integration/navigation_spec.rb",
    "spec/models/acts_as_phocodable_spec.rb",
    "spec/phocoder_rails_spec.rb",
    "spec/routing/phocoder_routing_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jagthedrummer/phocoder-rails}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails engine for easy integration with phocoder.com}
  s.test_files = [
    "spec/controllers/phocoder_controller_spec.rb",
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/models/image_upload.rb",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/secret_token.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/routes.rb",
    "spec/dummy/db/migrate/001_create_image_uploads.rb",
    "spec/engine_spec.rb",
    "spec/helpers/phocoder_helper_spec.rb",
    "spec/integration/navigation_spec.rb",
    "spec/models/acts_as_phocodable_spec.rb",
    "spec/phocoder_rails_spec.rb",
    "spec/routing/phocoder_routing_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0.3"])
      s.add_runtime_dependency(%q<capybara>, [">= 0.3.9"])
      s.add_runtime_dependency(%q<webrat>, [">= 0"])
      s.add_runtime_dependency(%q<phocoder-rb>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-debug>, [">= 0.10.3"])
      s.add_development_dependency(%q<rspec-rails>, ["= 2.4.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0.3"])
      s.add_dependency(%q<capybara>, [">= 0.3.9"])
      s.add_dependency(%q<webrat>, [">= 0"])
      s.add_dependency(%q<phocoder-rb>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0.10.3"])
      s.add_dependency(%q<rspec-rails>, ["= 2.4.1"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0.3"])
    s.add_dependency(%q<capybara>, [">= 0.3.9"])
    s.add_dependency(%q<webrat>, [">= 0"])
    s.add_dependency(%q<phocoder-rb>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0.10.3"])
    s.add_dependency(%q<rspec-rails>, ["= 2.4.1"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

