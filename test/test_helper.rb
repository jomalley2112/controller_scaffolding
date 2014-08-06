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

def assert_no_code
  assert_no_file "app/controllers/#{@contr_name}_controller.rb"
  assert_file "config/routes.rb" do |routes|
    assert_no_match %r(resources :#{@contr_name}), routes
  end
  assert_no_directory "app/views/#{@contr_name}"
  assert_no_file "app/views/application/_flash_messages.html.haml"
  assert_no_file "app/views/application/_pagination.html.haml"
  assert_no_file "app/views/application/_validation_errors.html.haml"
  assert_no_file "app/controllers/concerns/ext_index_nav.rb"
  assert_no_file "app/controllers/concerns/ext_form_submit.rb"
  assert_no_file "app/assets/stylesheets/controller_scaffolding.css.scss"
  assert_no_file "app/assets/javascripts/ext_index_nav.js"
  assert_file "app/controllers/application_controller.rb" do |ctrl|
    assert_no_match(/include ExtIndexNav/, ctrl)
    assert_no_match(/include ExtFormSubmit/, ctrl)
  end
  assert_file "app/assets/javascripts/application.js" do |app_js|
    assert_no_match(/\/\/= require jquery/, app_js)
    assert_no_match(/\/\/= require jquery_ujs/, app_js)
  end
  assert_file "app/views/layouts/application.html.erb" do |app_layout|
    assert_no_match(/<%= render 'flash_messages' %>/, app_layout)
  end
end

def assert_all_code
	assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
    @actions.each do |a|
      assert_instance_method a, p_ctrl do |action|
        assert_match(/\.paginate\(per_page: @per_page, page: @page\)/, action) if a == "index"
      end
    end
  end
  assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
    assert_match %r(def #{@contr_name.singularize}_params), p_ctrl
  end
  assert_file "config/routes.rb" do |routes|
    assert_match %r(resources :#{@contr_name}), routes
  end
  assert_file "app/views/#{@contr_name}/index.html.haml"
  assert_file "app/views/#{@contr_name}/new.html.haml"
  assert_file "app/views/#{@contr_name}/edit.html.haml"
  assert_file "app/views/#{@contr_name}/_form.html.haml"
  assert_file "app/views/application/_flash_messages.html.haml"
  assert_file "app/views/application/_pagination.html.haml"
  assert_file "app/views/application/_validation_errors.html.haml"
  assert_file "app/controllers/application_controller.rb", /include ExtIndexNav/
  assert_file "app/controllers/application_controller.rb", /include ExtFormSubmit/
  assert_file "app/assets/javascripts/application.js", /\/\/= require jquery/
  assert_file "app/assets/javascripts/application.js", /\/\/= require jquery_ujs/
  assert_file "app/views/layouts/application.html.erb", /<%= render 'flash_messages' %>/
end

