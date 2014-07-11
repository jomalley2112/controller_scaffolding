# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
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
