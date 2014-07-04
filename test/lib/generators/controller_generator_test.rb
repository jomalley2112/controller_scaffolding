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
    assert_file "app/views/people/index.html.haml"
    assert_file "app/views/people/new.html.haml"
  end


  def setup
  	#puts "about to run rails g model"
  	#%x(cd test/dummy; rails g model Person first_name:string last_name:string email:string title:string dob:datetime is_manager:boolean)
  	#sleep 5
    #%x(cd test/dummy; rake db:migrate; rake db:test:prepare)
    #sleep 5
  end

  def cleanup
		#%x(cd test/dummy; rails d model Person first_name:string last_name:string email:string title:string dob:datetime is_manager:boolean)  	
  	#%x(cd test/dummy; rake db:rollback STEP=1)
  	#%x(rm app/models/concerns/person.rb)
  	#%x(rm test/models/person_test.rb)
    #delete migration file
    # mig_dir_loc = "test/dummy/db/migrate"
    # migr_dir = Dir.new(mig_dir_loc)
    # migr_dir.each do |filename|
    #   File.delete("#{mig_dir_loc}/#{filename}") if filename =~ /create_people\.rb/
    # end
  end
end