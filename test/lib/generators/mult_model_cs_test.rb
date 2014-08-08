#The main purpose of this test is to make sure the locales/en.yml file gets the pagination
# message entries added to it in the correct way...especially by not repeating lines when
# the generator is run for multiple models
require 'test_helper'

class MultModelCSTest < Rails::Generators::TestCase

	tests Rails::Generators::ControllerScaffoldingGenerator
	destination File.expand_path("../tmp", File.dirname(__FILE__))
  
  def setup
    @actions = %w(index new create edit update destroy custom_action)
    @opts = %w(--force --quiet --template-engine=haml)
    @people_args = ["people"] | @actions | @opts
    @dino_args = ["dinosaurs"] | @actions | @opts
    prepare_destination
    copy_dummy_files
  end

  #just to make sure everything gets cleaned out
  def teardown
    run_generator @people_args , {:behavior => :revoke}
    run_generator @dino_args , {:behavior => :revoke}
  end

  test "locale file has correct entries for just people model" do
    people_yml = %Q`will_paginate:
    models:
      people:
        zero: People
        one: Person
        other: People
    page_entries_info:
      multi_page_html: Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b>
        %{model}
      single_page_html:
        zero: No %{model} found
        one: Displaying <b>1</b> %{model}
        other: Displaying <b>all&nbsp;%{count}</b> %{model}`
    assert_file "config/locales/en.yml" do |en|
      assert_no_match people_yml, en
    end
    run_generator @people_args
    assert_file "config/locales/en.yml" do |en|
      assert_match people_yml, en
    end
  end

  test "locale file has correct entries for just dinosaur model" do
    dinosaur_yml = %Q`will_paginate:
    models:
      dinosaurs:
        zero: Dinosaurs
        one: Dinosaur
        other: Dinosaurs
    page_entries_info:
      multi_page_html: Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b>
        %{model}
      single_page_html:
        zero: No %{model} found
        one: Displaying <b>1</b> %{model}
        other: Displaying <b>all&nbsp;%{count}</b> %{model}`
    assert_file "config/locales/en.yml" do |en|
      assert_no_match dinosaur_yml, en
    end
    run_generator @dino_args
    assert_file "config/locales/en.yml" do |en|
      assert_match dinosaur_yml, en
    end
  end

  test "locale file has correct entries for both models" do
    people_n_dinosaur_yml = %Q`will_paginate:
    models:
      people:
        zero: People
        one: Person
        other: People
      dinosaurs:
        zero: Dinosaurs
        one: Dinosaur
        other: Dinosaurs
    page_entries_info:
      multi_page_html: Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b>
        %{model}
      single_page_html:
        zero: No %{model} found
        one: Displaying <b>1</b> %{model}
        other: Displaying <b>all&nbsp;%{count}</b> %{model}`
    assert_file "config/locales/en.yml" do |en|
      assert_no_match "People", en
      assert_no_match "Dinosaur", en
    end
    run_generator @people_args
    run_generator @dino_args
    assert_file "config/locales/en.yml" do |en|
      assert_match people_n_dinosaur_yml, en
    end
  end

end