require 'spec_helper'

describe "People" do
	# before(:all) do
	# 	puts "\nAbout to invoke run rails g controller"
 #  	%x(rails g controller people index new create edit update destroy --quiet --force)
 #  	Rails.application.reload_routes!
 #  end

 #  after(:all) do
 #  	puts "\nAbout to revoke run rails g controller"
 #  	%x(rails d controller people index new create edit update destroy --quiet --force)
 #  end

  
  describe "Index" do
    it "displays the correct columns in the correct order" do
    	visit people_path
    	th_arr = first("table.outer-list").first("thead").all("th")
    	th_arr.map { |th| th.text.strip }.reject(&:blank?).should eq ["First name", "Last name",	"Email", "Title", "Dob", "Is manager"]
    end
    describe "Pagination" do
    	describe "page info" do
    		describe "multiple items" do
	    		before(:each) do
	  		    (1..31).each do |i|
	  		    	FactoryGirl.create(:person)
	  		    end
	    		end  

	    		it "shows the correct page info message" do
	    			visit people_path
	    			page.should have_content("Displaying 1 - 15 of 31 People")
	    			visit people_path(page: "2", per_page: "15")
	    			page.should have_content("Displaying 16 - 30 of 31 People")
	    			visit people_path(per_page: "100")
	    			page.should have_content("Displaying all 31 People")
	    		end

	    	end

	    	describe "one item" do
	    		before { FactoryGirl.create(:person) }
	    	  it "shows the correct page info message" do
	    			visit people_path
	    			page.should have_content("Displaying 1 Person")
	    		end
	    	end

	    	describe "zero items" do
	    		it "shows the correct page info message" do
	    			visit people_path
	    			page.should have_content("No entries found")
	    		end
	    	end

    	end
    	

    	####################################
    	describe "page navigation" do
    		before(:each) do
  		    (1..31).each do |i|
  		    	FactoryGirl.create(:person)
  		    end
    		end 
    		describe "items per page" do
	    	  it "displays 15 per page by default" do
	    	  	visit people_path
		      	people_displayed(page).should == 15
		      end 

          it "displays 20 items per page when selected by user", :js => true do
             visit people_path
             select("20", from: "People per page:")
             people_displayed(page).should == 20
             expect(page).to have_select("per_page", selected: '20') #Assert js reselects proper val
           end 

           it "displays 10 items per page when selected by user", :js => true do
             visit people_path
             select("10", from: "People per page:")
             people_displayed(page).should == 10
           end 

           it "displays all items per page when selected by user", :js => true do
             visit people_path
             select("All", from: "People per page:")
             people_displayed(page).should == 31
             expect(page).to have_select("per_page", selected: 'All')
           end
	    	end

        describe "pagination links" do
          it "responds correctly to user", :js => false do
            visit people_path(page: "1", per_page: "10")
            page.should have_content("Displaying 1 - 10 of 31 People")
            click_link("2")
            page.should have_content("Displaying 11 - 20 of 31 People")
            first("a.previous_page").click #Previous link
            first("table.outer-list").first(:xpath, "tbody/tr/td").text.should eq "John_1"
            first("a.next_page").click #Next link
            first("table.outer-list").first(:xpath, "tbody/tr/td").text.should eq "John_11"
          end
          
        end

    	end
    	
    	
    end
  end

  describe "New/Edit Form" do
    #it has the correct fields in the correct order
    #it redirects to the right page
    #it has the correct field types (may be tought to test)
  end

private

def people_displayed(page)
  page.first("table.outer-list").first("tbody").all(:xpath, "tr[not(@id='pagination-row')]").count
end
  

end
