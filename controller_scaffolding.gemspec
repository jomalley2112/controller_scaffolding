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
  s.summary     = "Creates controller and scaffolding for the model specified."
  s.description = %Q`Usage: $ rails g controller users index new create edit update destroy 
                    [--skip-ext-index-nav] [--skip-ext-form-submit]
                    Arguments: 1. The name of the existing model (as plural), 2. Space separated list of controller actions
                    Options: 1. [--skip-ext-index-nav] = Skip extended index navigation functionality
                             2. [--skip-ext-form-submit] = Skip extend form submission functionality`
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 4.1.1'
  s.add_dependency 'will_paginate', '~> 3.0.5'
  s.add_dependency 'haml-rails', '~> 0.5.3'
  s.add_dependency 'sass-rails', '~> 4.0.3'
  s.add_dependency 'jquery-rails', '~> 3.1.1'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry-rails"

  
end
