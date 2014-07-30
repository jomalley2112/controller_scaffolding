require 'generators/controller/controller_scaffolding_generator'

#The main function of this test is to verify the expected behavior of the generator when the 
# index edit update and custom_action actions are passed to it. The correct actions and views should be generated
class SomeActionsGeneratorTest < Rails::Generators::TestCase
	tests Rails::Generators::ControllerScaffoldingGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  def setup
    @contr_name = "people"
    @actions = %w(index edit update custom_action)
    @opts = %w(--force --quiet --template-engine=haml)
    @args = [@contr_name] | @actions | @opts
    prepare_destination
    copy_dummy_files
  end

  def teardown
    run_generator @args , {:behavior => :revoke}
  end

  test "Controller was created properly with appropriate actions" do
    assert_no_file "app/controllers/#{@contr_name}_controller.rb"

    %w(index edit _form custom_action).each do |action|
      assert_no_file "app/views/#{@contr_name}/#{action}.html.haml"
    end
      
  	run_generator @args
  	
    assert_file "app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
  		@actions.each do |a|
	  		assert_instance_method a, p_ctrl do |action|
	  			assert_match(/\.paginate\(per_page: @per_page, page: @page\)/, action) if a == "index"
			  end
        assert_not(p_ctrl.match(/def new/))
        assert_not(p_ctrl.match(/def create/))
        assert_not(p_ctrl.match(/def destroy/))
      end
  	end

    %w(index edit _form custom_action).each do |action|
      assert_file "app/views/#{@contr_name}/#{action}.html.haml"
    end 
    assert_no_file "app/views/#{@contr_name}/new.html.haml"
   
  end

end