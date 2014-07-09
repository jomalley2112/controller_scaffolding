require 'spec_helper'

describe "People" do
	before(:all) do
		puts "\nAbout to invoke run rails g controller"
  	%x(rails g controller people index new create edit update destroy --quiet --force)
  	Rails.application.reload_routes!
  end

  after(:all) do
  	puts "\nAbout to revoke run rails g controller"
  	%x(rails d controller people index new create edit update destroy --quiet --force)
  end

  describe "Index page" do
    it "displays the correct columns in the correct order" do
    	visit people_path
    	th_arr = first("table.outer-list").first("thead").all("th")
    	th_arr.map { |th| th.text.strip }.reject(&:blank?).should eq ["First name", "Last name",	"Email", "Title", "Dob", "Is manager"]
    end
  end

  #private

  # def html_table_to_array(table_element)
  #   thead = table_element.first("thead") #allow a param to be passed that says whether or not there is a thead element
  #   hdr_tr = thead.first("tr")
  #   headers = hdr_tr.all("th")
    
  #   tbody = table_element.first("tbody")
  #   trs = tbody.all("tr")
  #   tmp_array = Array.new
    
  #   trs.each_with_index do |tr, i|
  #     tds = tr.all("td")
  #     cell_hash = Hash.new
  #     tds.each_with_index do |td, i|
  #        cell_hash[headers[i].text.tableize.singularize.gsub(/\s/, "_").to_sym] = td.text unless headers[i].text == "" #only add columns with some kind of column header
  #     end
  #     tmp_array << cell_hash
  #   end
  #   return tmp_array
  # end
end
