require 'spec_helper'

describe "People" do
	before(:all) do
    cmd_str = 'rails g controller_scaffolding people index new create edit update destroy' 
    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
		puts "\n#{cmd_str}"
  	%x(#{cmd_str})
    # puts "\n\nRELOADING ROUTES FILE:\n\n"
    # puts  %x(cat config/routes.rb)
    #Reload changed resources
    Rails.application.reload_routes!
  end

  after(:all) do
  	cmd_str = 'rails d controller_scaffolding people index new create edit update destroy' 
    cmd_str << ' --template-engine=haml --quiet --force --skip-assets --skip-test-framework --skip-helper' 
    puts "\n#{cmd_str}"
    %x(#{cmd_str})
  end

  
  describe "Index" do
        
    it "displays the correct columns in the correct order" do
    	visit people_path
      th_arr = first("table.outer-list").first("thead").all("th")
    	th_arr.map { |th| th.text.strip }.reject(&:blank?).should 
        eq ["First name", "Last name",	"Email", "Title", "Dob", "Is manager"]
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

	    	describe "one item", :js => true do
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
          it "responds correctly to user", :js => true do
            visit people_path(page: "1", per_page: "10")
            page.should have_content("Displaying 1 - 10 of 31 People")
            click_link("2")
            page.should have_content("Displaying 11 - 20 of 31 People")
            first("a.previous_page").click #Previous link
            first("table.outer-list").first(:xpath, "tbody/tr/td").text.should eq Person.find(1).first_name
            first("a.next_page").click #Next link
            first("table.outer-list").first(:xpath, "tbody/tr/td").text.should eq Person.find(11).first_name
          end
        end

    	end
    	
    end
    describe "Links" do
      before { @person = FactoryGirl.create(:person) }
      it "allows user to edit" do
        visit people_path
        click_link("Edit")
        current_path.should eq edit_person_path(@person)
      end
      it "allows user to delete", :js => true do
        visit people_path
        expect {
          click_link("Del")
          page.driver.browser.switch_to.alert.accept
          sleep 1
        }.to change(Person, :count).by(-1)
      end
    end

    describe "Search and Sort" do
      it "displays a search box and a find and clear button", :js => false do
        visit people_path
        page.should have_selector("input#search_for")
        page.should have_selector("button#submit-search")
        page.should have_selector("button#clear-search")
      end

      it "displays a sort select list populated with all of the correct options", :js => false do
        visit people_path
        sel_opts = ["First name","First name [desc]","Last name","Last name [desc]","Email", 
                   "Email [desc]","Title", 
                   "Title [desc]","Dob","Dob [desc]","Is manager","Is manager [desc]"]
        page.should have_select('sort_by', :options => sel_opts)
      end
      it "clears the search", :js => true do
        visit people_path
        fill_in("search_for", :with => "Search Text")
        click_button("clear-search")
        first("input#search_for").value.should eq ""
      end

      describe "has functional sort capability" do
        before(:each) do
          (1..50).each do 
            FactoryGirl.create(:person, first_name: "John_#{Random.rand(1..99)}", 
              last_name: "Doe_#{Random.rand(1..99)}", email: "johndoesemail_#{Random.rand(1..99)}@domain.com")
          end
        end
        it "sorts by last name descending when selected", :js => true do
          visit people_path
          select("Last name [desc]", :from => "sort_by")
          sleep 0.5
          last_names = all(:xpath, "//table/tbody/tr/td[2]")
          last_names.map(&:text).should == last_names.map(&:text).sort.reverse
        end

      end
      describe "has functional search capability", :js => true do
        before(:each) do
          FactoryGirl.create(:person, first_name: "Fred", last_name: "Bradley")
          FactoryGirl.create(:person, first_name: "Brad", last_name: "Johnson")
          FactoryGirl.create(:person, first_name: "John", last_name: "Williams")
          FactoryGirl.create(:person, first_name: "Will", last_name: "Farley")
          FactoryGirl.create(:person, first_name: "Joseph", email: "jo@brads.net")
        end
        it "returns only rows that have first or last name matching case-insensitive 'wIlL'", :js => false do
          visit people_path
          people_displayed(page).should eq 5
          fill_in("search_for", :with => "wIlL")
          click_button("submit-search")
          people_displayed(page).should eq 2
        end
      end
    end
    
  end

  describe "New/Edit Form" do
    
    describe "fields" do
      it "new form has the correct field labels in the correct order" do
        visit new_person_path
        field_labels = page.all(:xpath, "//form[@class='new_person']/table[@class='outer']/tr/td/label").map(&:text)
        field_labels.should eq ["First name", "Last name", "Email", "Title", "Dob", "Is manager"]
      end
      it "edit form has the correct field labels in the correct order" do
        person = FactoryGirl.create(:person)
        visit edit_person_path(person)
        field_labels = page.all(:xpath, "//form[@class='edit_person']/table[@class='outer']/tr/td/label").map(&:text)
        field_labels.should eq ["First name", "Last name", "Email", "Title", "Dob", "Is manager"]
      end  
      describe "values" do
        it "adds the correct values to its fields", :js => true do
          visit new_person_path
          fill_in("First name", :with => "Johnathan")
          fill_in("Last name", :with => "Jones")
          fill_in("Email", :with => "jj@domain.com")
          fill_in("Title", :with => "Sales Rep")
          dt = (Time.now - 2.years)
          set_rails_datetime(dt, "person_dob")
          click_button("Save & Back to List")
          page.should have_content("Created Person successfully")
          page.should have_content("Johnathan")
          page.should have_content("Jones")
          page.should have_content("jj@domain.com")
          page.should have_content("Sales Rep")
          #TODO: Pain to test datetime because of UTC...may just wait until datepicker functionality is added
          #page.should have_content(dt.utc)
        end
        it "updates its fields correctly", :js => false do
          person = FactoryGirl.create(:person, dob: (Time.now - 2.years))
          visit edit_person_path(person)
          fill_in("First name", :with => "Jerry")
          fill_in("Last name", :with => "James")
          fill_in("Email", :with => "jjames@domain.com")
          fill_in("Title", :with => "Manager")
          dt = (Time.now - 1.year)
          set_rails_datetime(dt, "person_dob")
          click_button("Save & Back to List")
          page.should have_content("Updated Person successfully")
          page.should have_content("Jerry")
          page.should have_content("James")
          page.should have_content("jjames@domain.com")
          page.should have_content("Manager")
          #TODO: Pain to test datetime because of UTC...may just wait until datepicker functionality is added
          #page.should have_content(dt.utc)
        end  
      end
      
    end
    
    
    #Note: if this fails make sure the person model has the "validates :first_name" call
    it "displays validation errors" do
      visit new_person_path
      click_button("Save & Back to List")
      page.should have_content("Unable to create Person for the following 1 reason:")
      page.should have_content("First name can't be blank")
    end

    describe "form submission landing page and flash messages" do
      it "redirects to the index page with success message" do
        visit new_person_path
        fill_in("First name", :with => "John")
        click_button("Save & Back to List")
        page.should have_content("Created Person successfully")
        current_path.should eq people_path
      end  
      it "redirects to the new page with success message" do
        visit new_person_path
        fill_in("First name", :with => "John")
        click_button("Save & Reload")
        page.should have_content("Created Person successfully")
        current_path.should eq new_person_path
      end
      it "redirects to the edit page with success message" do
        person = FactoryGirl.create(:person)
        visit edit_person_path(person)
        fill_in("First name", :with => "John")
        click_button("Save & Reload")
        page.should have_content("Updated Person successfully")
        current_path.should eq edit_person_path(person)
      end
    end

    #TODO: it has the correct field types (may be tough to test)
  end


end
