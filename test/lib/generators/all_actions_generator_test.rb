require 'test_helper'
require 'generators/controller/controller_scaffolding_generator'

#The main function of this test is to verify the expected behavior of the generator when no
# actions are passed to it. All RESTful actions and views should be generated.
class AllActionsGeneratorTest < Rails::Generators::TestCase
	tests Rails::Generators::ControllerScaffoldingGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  def setup
    @contr_name = "people"
    @actions = %w(index new create edit update destroy)
    @opts = %w(--force --quiet --template-engine=haml)
    @args = [@contr_name] | @opts #Not passing any actions in!
    prepare_destination
    copy_dummy_files
  end

  def teardown
    run_generator @args , {:behavior => :revoke}
  end

  test "Controller was created properly with appropriate actions" do
    assert_no_file "app/controllers/#{@contr_name}_controller.rb"

    %w(index new edit _form).each do |action|
      assert_no_file "app/views/#{@contr_name}/#{action}.html.haml"
    end
      
  	run_generator @args
  	assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
  		@actions.each do |a|
	  		assert_instance_method a, p_ctrl do |action|
	  			assert_match(/\.paginate\(per_page: @per_page, page: @page\)/, action) if a == "index"
			  end
			end
  	end

    %w(index new edit _form).each do |action|
      assert_file "app/views/#{@contr_name}/#{action}.html.haml"
    end 
   
  end



end