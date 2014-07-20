ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'database_cleaner'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  
  config.use_transactional_fixtures = false
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
end

def people_displayed(page)
  page.first("table.outer-list").first("tbody").all(:xpath, "tr[not(@id='pagination-row')]").count
end

def set_rails_datetime(time, id_prefix)
  select time.year, from: "#{id_prefix}_1i"
  select time.strftime("%B"), from: "#{id_prefix}_2i"
  begin
    select time.day, from: "#{id_prefix}_3i" #This could raise ambiguous match error
  rescue
    puts "set_rails_datetime() rescued an error. Day was #{time.day} not selected."
  end
  #pad with zeros to disambiguate
  select(('%02i' % time.hour), from: "#{id_prefix}_4i")
  select(('%02i' % time.min), from: "#{id_prefix}_5i")
end
