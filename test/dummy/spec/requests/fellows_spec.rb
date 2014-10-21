require 'spec_helper'

#The main reson for this spec is to make sure the --skip-search-sort generator option works as
# expected when running generator multiple times
RSpec.describe "Fellows", :type => :request do
  
	describe "index" do
	  before(:each) do
  	  visit fellows_path
  	end
	  describe "with search/sort functionality" do
	  	
	  	before(:all) do
		    cmd_str = 'rails g controller_scaffolding fellows index ' 
		    cmd_str << ' --template-engine=erb --quiet --force --skip-assets --skip-test-framework --skip-helper' 
				puts "\n#{cmd_str}"
		  	%x(#{cmd_str})
		    Rails.application.reload_routes!
		  end
		  after(:all) do
		  	cmd_str = 'rails d controller_scaffolding fellows index ' 
		    cmd_str << ' --template-engine=erb --quiet --force --skip-assets --skip-test-framework --skip-helper' 
		    puts "\n#{cmd_str}"
		    %x(#{cmd_str})
		  end

	    it "displays search form", :js => true do
	    	page.should have_selector("input#search_for")
        page.should have_selector("button#submit-search")
        page.should have_selector("button#clear-search")  	
	    end
	    
	    it "displays sort form" do
	    	page.should have_select('sort_by')
	    end

	    it "has sort dropdown filled in with correct columns" do
	    	sel_opts = ["First name","First name [desc]","Last name","Last name [desc]","Email", 
                   "Email [desc]","Title", 
                   "Title [desc]","Dob","Dob [desc]","Is manager","Is manager [desc]"]
        page.should have_select('sort_by', :options => sel_opts)
	    end
	  end
	  
	  describe "without search/sort functionality", :js => true do
	  	
	  	before(:all) do
		    cmd_str = 'rails g controller_scaffolding fellows index --skip-search-sort ' 
		    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
				puts "\n#{cmd_str}"
		  	%x(#{cmd_str})
		    Rails.application.reload_routes!
		  end
		  after(:all) do
		  	cmd_str = 'rails d controller_scaffolding fellows index  --skip-search-sort ' 
		    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
		    puts "\n#{cmd_str}"
		    %x(#{cmd_str})
		  end

	    it "does not have a search form" do
	    	page.should_not have_selector("input#search_for")
        page.should_not have_selector("button#submit-search")
        page.should_not have_selector("button#clear-search")
	    end
	    it "does not have a sort form" do
	    	page.should_not have_select('sort_by')
	    end
	  end
	end

end
