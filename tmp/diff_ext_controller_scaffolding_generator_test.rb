require 'test_helper'
require 'generators/controller/controller_scaffolding_generator'

class ExtControllerScaffoldingGeneratorTest < Rails::Generators::TestCase
	tests Rails::Generators::ControllerScaffoldingGenerator
	destination "#{::Rails.root.to_s}/" #File.expand_path("../ctrlr_tmp", File.dirname(__FILE__))
  
  def setup
    @contr_name = "people"
    @actions = %w(index new create edit update destroy custom_action)
    @opts = %w(--force --quiet)
    @args = [@contr_name] | @actions | @opts
    #prepare_destination
  end

  def teardown
    run_generator @args , {:behavior => :revoke}
  end

  test "Controller was created properly with appropriate actions" do
  	assert_no_file "#{::Rails.root.to_s}/app/controllers/#{@contr_name}_controller.rb"

  	run_generator @args
  	
  	assert_file "#{::Rails.root.to_s}/app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
  		@actions.each do |a|
	  		puts "Looking for action #{a}"
	  		assert_instance_method a, p_ctrl do |action|
	  			assert_match(/\.paginate\(per_page: @per_page, page: @page\)/, action) if a == "index"
			  end
			end
  	end 
 
        #strong params method definition
    assert_file "#{::Rails.root.to_s}/app/controllers/#{@contr_name}_controller.rb" do |p_ctrl|
      assert_match %r(def #{@contr_name.singularize}_params), p_ctrl
    end

  end

  test "Routes were added properly" do
    assert_file "#{::Rails.root.to_s}/config/routes.rb" do |routes|
      assert_no_match %r(resources :#{@contr_name}), routes
    end

    run_generator @args

    assert_file "#{::Rails.root.to_s}/config/routes.rb" do |routes|
      assert_match %r(resources :#{@contr_name}), routes
    end
  end


  test "Search and Sort functionality files get copied" do
    assert_no_file "app/views/application/_sort_form.html.haml"
    assert_no_file "app/views/application/_search_form.html.haml"
    assert_no_file "app/assets/javascripts/sql_search_n_sort.js"
    assert_no_file "app/helpers/sql_search_n_sort_helper.rb/"
    run_generator @args
    assert_file "app/views/application/_sort_form.html.haml"
    assert_file "app/views/application/_search_form.html.haml"
    assert_file "app/assets/javascripts/sql_search_n_sort.js"
    assert_file "app/helpers/sql_search_n_sort_helper.rb/"
  end

  test "Lines needed for Search and Sort get inserted into existing files" do
    assert_file "app/controllers/application_controller.rb" do |ac|
      assert_no_match "include SqlSortSetup", ac
      assert_no_match %r(before_filter :setup_sql_sort, :only => \[:index.*\]), ac
    end
    assert_file "app/assets/javascripts/application.js" do |ajs|
      assert_no_match "\n//= require jquery", ajs
    end
    assert_file "app/models/#{@contr_name.singularize}.rb" do |mod|
      assert_no_match "extend SqlSearchableSortable", mod 
      assert_no_match "sql_searchable", mod
      assert_no_match "sql_sortable", mod
    end

    run_generator @args
    
    assert_file "app/controllers/application_controller.rb" do |ac|
      assert_match "include SqlSortSetup", ac
      assert_match %r(before_filter :setup_sql_sort, :only => \[:index.*\]), ac
    end
    assert_file "app/assets/javascripts/application.js" do |ajs|
      assert_match "\n//= require jquery", ajs
    end
    # assert_file "app/models/#{@contr_name.singularize}.rb" do |mod|
    #   assert_match %r(\n.*extend SqlSearchableSortable), mod 
    #   assert_match %r(\n.*sql_searchable), mod
    #   assert_match %r(\n.*sql_sortable), mod
    # end
  end

  private
    #TODO: SHould add a helper for this to Rails::Generators::TestCase
    # so you could do like: stage_rails_files("../dummy_test_files", "app", "config", ...)
    def copy_dummy_files
      dummy_file_dir = File.expand_path("../dummy_test_files", __FILE__)
      FileUtils.cp_r("#{dummy_file_dir}/app", "#{destination_root}/app")
      FileUtils.cp_r("#{dummy_file_dir}/config", "#{destination_root}/config")
    end
end