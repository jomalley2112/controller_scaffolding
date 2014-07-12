# ControllerScaffolding #

Creates controller and extended scaffolding for the model specified.

To use this gem add the following line to your project's Gemfile:
`gem 'controller_scaffolding', :git => "https://github.com/jomalley2112/controller_scaffolding.git"`
and then run `bundle install`

- Dependencies:
	- 'rails', '~> 4.1.1'
  - 'will_paginate', '~> 3.0.5'
  - 'haml-rails', '~> 0.5.3'
  - 'sass-rails', '~> 4.0.3'
  - 'jquery-rails', '~> 3.1.1'

- Development Environment Dependencies:
	- "sqlite3"
	- "rspec-rails"
	- "capybara"
	- "selenium-webdriver"
	- "factory_girl_rails"
	- "database_cleaner"
	

Usage: `$ rails g|d controller_scaffolding users index new create edit update destroy --template-engine=haml
[--skip-ext-index-nav] [--skip-ext-form-submit] [--quiet] [--force] [--skip-assets] [--skip-test-framework] [--skip-helper]`

*Note: You must restart Rails after running this generator*

- Arguments:
	1. The name of the existing model (as plural)  
	2. A space-separated list of controller actions  

- Options:
	1. [--skip-ext-index-nav] = Skip extended index navigation functionality  
  2. [--skip-ext-form-submit] = Skip extend form submission functionality  
  3. [--quiet] = Suppress info messages
  4. [--force] = Overwrite files without prompting


Description:
	
* Controller
	* Adds functionality to support pagination for the index page if extended index navigation was  selected.
	* Creates any of the normal REST actions that were passed to the generator. These actions will have built-in functionality that handles success and validation error messages.
	* Adds a method to handle strong params. *This should be reviewed to make sure that all of the  params that are allowed, should be allowed*.

* Application Controller
	* Includes concerns ExtFormSubmit and ExtIndexNav depending on configuration


* Concerns
	* installs ext_index_nav.rb if extended index navigation selected
	* installs ext_form_submit.rb if extended form submission selected

* Routes
	* Adds a resources line for the model specified. *This may be an issue if the routes file already contains  entries for the resource*

* Extended index navigation (optional):
	* Generates an index view file for the model specified containing columns with headers for all  fields not generated automatically by rails (Everything but id, created_at and updated_at). Certain  keywords are given priority when found in the field names which makes them show up before  others (eg. name, email)
	* Generates pagination functionality for the index page
	* Adds some styling to the index page

* Extended form submission (optional):
	* Generates a form partial which is utilized by both the new and edit views for the model specified.
	* The form will have input labels and input fields of the proper type prioritized the same way as  the index columns
	* The form has two buttons. 
		* One button performs the "normal" action of saving and redirecting to the list of resources.
		* The other button Saves and reloads the current page allowing the user to add multiple items  without having to go back to the index page each time.
	* Adds some styling to the form
	* Adds functionality to display flash messages and validation errors.

* Assets
	* Javascript
		* Installs ext_index_nav.js if extended index navigation is selected.
		* Requires jquery and jqwuery_ujs in application.js
	* Stylesheets
		* Installs controller_scaffolding.css.scss if either extended index navigation or extended form  submission are selected


This project uses MIT-LICENSE.