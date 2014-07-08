require 'test_helper'
#require 'rails/generators'
require 'generators/haml/controller/controller_generator'
require 'generators/controller/controller_generator'

class ControllerGeneratorTest < Rails::Generators::TestCase
  
  tests Haml::Generators::ControllerGenerator
	destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  #arguments @args #sets default args for gen call
  #setup :prepare_destination

  def setup
    @contr_name = "people"
    @actions = %w(index new create edit update destroy)
    @args = [@contr_name] | @actions
    prepare_destination
  end

  def teardown
    run_generator (@args | %w(--force)) , {:behavior => :revoke}
  end

  test "Assert all files are properly created" do
    run_generator @args
    #Views
    assert_file "app/views/#{@contr_name}/index.html.haml"
    assert_file "app/views/#{@contr_name}/new.html.haml"
    assert_file "app/views/#{@contr_name}/edit.html.haml"
    assert_file "app/views/#{@contr_name}/_form.html.haml"
    assert_no_file "app/views/#{@contr_name}/create.html.haml"
    assert_no_file "app/views/#{@contr_name}/update.html.haml"
    assert_no_file "app/views/#{@contr_name}/destroy.html.haml"
    #Partials
    assert_file "app/views/application/_flash_messages.html.haml"
    assert_file "app/views/application/_pagination.html.haml"
    assert_file "app/views/application/_validation_errors.html.haml"
    #TODO: I believe we need to test the other generator separately and test people_controller in there
    #Controller
    #assert_file "#{::Rails.root.to_s}/app/controllers/people_controller.rb"
    #Controller Concerns
    assert_file "app/controllers/concerns/ext_index_nav.rb"
    assert_file "app/controllers/concerns/ext_form_submit.rb"
    #Stylesheets
    assert_file "app/assets/stylesheets/controller_scaffolding.css.scss"
    #Javascripts
    assert_file "app/assets/javascripts/ext_index_nav.js"
  end

  test "Assert lines have been inserted into proper files" do
    assert_file "#{::Rails.root.to_s}/app/controllers/application_controller.rb" do |ctrl|
      assert_no_match(/include ExtIndexNav/, ctrl)
      assert_no_match(/include ExtFormSubmit/, ctrl)
    end
    assert_file "#{::Rails.root.to_s}/app/assets/javascripts/application.js" do |app_js|
      assert_no_match(/\/\/= require jquery/, app_js)
    end
    assert_file "#{::Rails.root.to_s}/app/views/layouts/application.html.erb" do |app_layout|
      assert_no_match(/<%= render 'flash_messages' %>/, app_layout)
    end
    assert_file "#{::Rails.root.to_s}/app/helpers/application_helper.rb" do |app_helper|
      assert_no_match(/def render_for_controller\(partial, local_vars\)/, app_helper)
    end
    
    run_generator @args
    
    assert_file "#{::Rails.root.to_s}/app/controllers/application_controller.rb", /include ExtIndexNav/
    assert_file "#{::Rails.root.to_s}/app/controllers/application_controller.rb", /include ExtFormSubmit/
    assert_file "#{::Rails.root.to_s}/app/assets/javascripts/application.js", /\/\/= require jquery/
    assert_file "#{::Rails.root.to_s}/app/views/layouts/application.html.erb", /<%= render 'flash_messages' %>/
    assert_file "#{::Rails.root.to_s}/app/helpers/application_helper.rb", /def render_for_controller\(partial, local_vars\)/
  end

  # test "Assert actions specified in command line are added to controller file" do
  #   run_generator @args
  #   @actions.each do |action|
  #     assert_file "app/controllers/#{@contr_name}_controller.rb"
  #   end
  # end


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