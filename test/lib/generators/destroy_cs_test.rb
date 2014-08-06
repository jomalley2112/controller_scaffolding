#To Teardown manually:
# rails d controller_scaffolding dinosaurs index new create edit update destroy custom_action --template-engine=haml

require 'test_helper'
require 'generators/controller/controller_scaffolding_generator'

class DestroyCsTest < Rails::Generators::TestCase
	tests Rails::Generators::ControllerScaffoldingGenerator
	destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  def setup
    @contr_name = "dinosaurs"
    @actions = %w(index new create edit update destroy custom_action)
    @opts = %w(--force --quiet --template-engine=haml)
    @args = [@contr_name] | @actions | @opts
    prepare_destination
    copy_dummy_files
    #puts "\nTESTING: rails g controller_scaffolding #{@args.join(" ")}\n"
  end

  #just to make sure everything gets cleaned out
  # def teardown
  #   run_generator @args , {:behavior => :revoke}
  # end

  test "None of the scaffold_generator files or code exists prior to running generator" do
    assert_no_code
  end

  test "All approppriate pieces are present after generate is run" do
    run_generator @args
    assert_all_code
  end

  test "All traces of controller_generator-generated code are removed after destroy is run" do
    run_generator @args
    run_generator @args , {:behavior => :revoke}
    assert_no_code
  end

end