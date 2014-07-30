require 'test_helper'
require 'generators/controller/controller_scaffolding_generator'

class ExtControllerScaffoldingGeneratorTest < Rails::Generators::TestCase
	tests Rails::Generators::ControllerScaffoldingGenerator
	#destination "#{::Rails.root.to_s}/" #File.expand_path("../ctrlr_tmp", File.dirname(__FILE__))
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  def setup
    @contr_name = "people"
    @actions = %w(index new create edit update destroy custom_action)
    @opts = %w(--force --quiet) # --template-engine=haml #thought it would need that option
    @args = [@contr_name] | @actions | @opts
    prepare_destination
    copy_dummy_files
  end

  def teardown
    run_generator @args , {:behavior => :revoke}
  end

  test "Controller was created properly with appropriate actions" do
  	assert_no_file "app/controllers/#{@contr_name}_controller.rb"
    #Note: This is the controller file that will be generated after the generator runs
    assert_no_file "app/controllers/#{@contr_name}_controller.rb"
      
  	run_generator @args
  	
  	assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
  		@actions.each do |a|
	  		assert_instance_method a, p_ctrl do |action|
	  			assert_match(/\.paginate\(per_page: @per_page, page: @page\)/, action) if a == "index"
			  end
			end
  	end 
   #strong params method definition
    assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
      assert_match %r(def #{@contr_name.singularize}_params), p_ctrl
    end
  end

  test "Routes were added properly" do
    assert_file "config/routes.rb" do |routes|
      assert_no_match %r(resources :#{@contr_name}), routes
    end

    run_generator @args

    assert_file "config/routes.rb" do |routes|
      assert_match %r(resources :#{@contr_name}), routes
    end
  end


end