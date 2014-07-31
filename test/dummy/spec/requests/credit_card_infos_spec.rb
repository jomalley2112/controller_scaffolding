require 'spec_helper'

describe "CreditCardInfos" do
	before(:all) do
    cmd_str = 'rails g controller_scaffolding credit_card_infos index new create --skip-search-sort' 
    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
		puts "\n#{cmd_str}"
  	%x(#{cmd_str})
    # puts "\n\nRELOADING ROUTES FILE:\n\n"
    # puts  %x(cat config/routes.rb)
    Rails.application.reload_routes!
  end

  after(:all) do
  	cmd_str = 'rails d controller_scaffolding credit_card_infos index new create --skip-search-sort' 
    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
    puts "\n#{cmd_str}"
    %x(#{cmd_str})
  end

  describe "index" do
  	describe "basic functionality" do
  	  before(:each) do
	  	  FactoryGirl.create(:credit_card_info)
	  	end
	    it "displays the credit card we added" do
	    	visit credit_card_infos_path
	    	page.should have_content("John Adams")
	    end
  	end
  	describe "pagination" do
  		before(:each) do
	  	  (1..31).each { FactoryGirl.create(:credit_card_info) }
	  	end
  	  it "shows the correct page info message" do
  	  	visit credit_card_infos_path
  			page.should have_content("Displaying 1 - 15 of 31 credit card infos")
  			visit credit_card_infos_path(page: "2", per_page: "15")
  			page.should have_content("Displaying 16 - 30 of 31 credit card infos")
  			visit credit_card_infos_path(per_page: "100")
  			page.should have_content("Displaying all 31 credit card infos")
  		end
  	end
  end
end