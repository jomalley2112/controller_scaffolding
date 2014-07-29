$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "controller_scaffolding/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "controller_scaffolding"
  s.version     = ControllerScaffolding::VERSION
  s.authors     = ["John O'Malley"]
  s.email       = ["jom@nycap.rr.com"]
  s.homepage    = "https://github.com/jomalley2112/controller_scaffolding"
  s.summary     = "Creates controller and extended scaffolding for the model specified."
  s.description = "Creates controller and extended scaffolding for the model specified."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'nokogiri', '=1.6.3.1'
  s.add_dependency 'rails', '~> 4.1'
  s.add_dependency 'will_paginate' #, '3.0.5'
  s.add_dependency 'haml-rails' #, '~> 0.5.3'
  s.add_dependency 'sass-rails', '~> 4.0.3'
  s.add_dependency 'jquery-rails' #, '~> 3.1.1'
  

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "faker"
  
end
