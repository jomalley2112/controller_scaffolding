# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'pry-rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

#TODO: SHould add a helper for this to Rails::Generators::TestCase
# so you could do like: stage_rails_files("../dummy_test_files", "app", "config", ...)
def copy_dummy_files
  dummy_file_dir = File.expand_path("../lib/generators/dummy_test_files", __FILE__)
  FileUtils.cp_r("#{dummy_file_dir}/app", "#{destination_root}/app")
  FileUtils.cp_r("#{dummy_file_dir}/config", "#{destination_root}/config")
end

