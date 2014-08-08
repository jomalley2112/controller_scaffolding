#To Teardown manually:
# rails d controller_scaffolding people index new create edit update destroy custom_action --template-engine=haml

require 'test_helper'

class ControllerScaffoldingGeneratorTest < Rails::Generators::TestCase
  
  tests Haml::Generators::ControllerScaffoldingGenerator
	destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  #arguments @args #sets default args for gen call
  #setup :prepare_destination

  def setup
    @contr_name = "people"
    @actions = %w(index new create edit update destroy)
    @opts = %w(--force) # --template-engine=haml #thought it would need option
    @args = [@contr_name] | @actions | @opts
    prepare_destination
    copy_dummy_files

  end

  def teardown
    run_generator @args , {:behavior => :revoke}
  end

  test "Assert all files are properly created" do
    #load "app/controllers/application_controller.rb"
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
    
    run_generator @args
    
    assert_file "app/controllers/application_controller.rb", /include ExtIndexNav/
    assert_file "app/controllers/application_controller.rb", /include ExtFormSubmit/
    assert_file "app/assets/javascripts/application.js", /\/\/= require jquery/
    assert_file "app/assets/javascripts/application.js", /\/\/= require jquery_ujs/
    assert_file "app/views/layouts/application.html.erb", /<%= render 'flash_messages' %>/
    
    # pagination_msgs = %Q`    models:
    #   #{@contr_name}:
    #     zero:  #{@contr_name.humanize}
    #     one:   #{@contr_name.singularize.humanize}
    #     other: #{@contr_name.humanize}
    # page_entries_info:
    #   multi_page_html: "Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b> %{model}"
    #   single_page_html:
    #     zero:  "No %{model} found"
    #     one:   "Displaying <b>1</b> %{model}"
    #     other: "Displaying <b>all&nbsp;%{count}</b> %{model}"`

    # assert_file "config/locales/en.yml" do |en|
    #   assert_match(pagination_msgs, en)
    # end
  end
  

end