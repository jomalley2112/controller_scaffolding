require 'test_helper'
#require 'rails/generators'
require 'generators/haml/controller/controller_generator'
require 'generators/controller/controller_generator'

class ControllerGeneratorTest < Rails::Generators::TestCase
  
	arguments %w(People index new create edit update destroy)
	tests Haml::Generators::ControllerGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "Assert all files are properly created" do
    run_generator
    #Views
    assert_file "app/views/people/index.html.haml"
    assert_file "app/views/people/new.html.haml"
    assert_file "app/views/people/edit.html.haml"
    assert_file "app/views/people/_form.html.haml"
    assert_no_file "app/views/people/create.html.haml"
    assert_no_file "app/views/people/update.html.haml"
    assert_no_file "app/views/people/destroy.html.haml"
    #Partials
    assert_file "app/views/application/_flash_messages.html.haml"
    assert_file "app/views/application/_pagination.html.haml"
    assert_file "app/views/application/_validation_errors.html.haml"
    #TODO: why doesn't this file exist?
    #Controller
    #assert_file "app/controllers/people_controller.rb"
    #Controller Concerns
    assert_file "app/controllers/concerns/ext_index_nav.rb"
    assert_file "app/controllers/concerns/ext_form_submit.rb"
    #Stylesheets
    assert_file "app/assets/stylesheets/controller_scaffolding.css.scss"
    #Javascripts
    assert_file "app/assets/javascripts/ext_index_nav.js"

  end

  #make sure "app/assets/javascripts/application.js" has //= require jquery


  # def setup
  # 	#puts "about to run rails g model"
  # 	#%x(cd test/dummy; rails g model Person first_name:string last_name:string email:string title:string dob:datetime is_manager:boolean)
  # 	#sleep 5
  #   #%x(cd test/dummy; rake db:migrate; rake db:test:prepare)
  #   #sleep 5
  # end

  # def cleanup
		# #%x(cd test/dummy; rails d model Person first_name:string last_name:string email:string title:string dob:datetime is_manager:boolean)  	
  # 	#%x(cd test/dummy; rake db:rollback STEP=1)
  # 	#%x(rm app/models/concerns/person.rb)
  # 	#%x(rm test/models/person_test.rb)
  #   #delete migration file
  #   # mig_dir_loc = "test/dummy/db/migrate"
  #   # migr_dir = Dir.new(mig_dir_loc)
  #   # migr_dir.each do |filename|
  #   #   File.delete("#{mig_dir_loc}/#{filename}") if filename =~ /create_people\.rb/
  #   # end
  # end
end