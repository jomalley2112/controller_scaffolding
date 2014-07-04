= ControllerScaffolding

Creates controller and extended scaffolding for the model specified.

Usage: $ rails g controller users index new create edit update destroy 
[--skip-ext-index-nav] [--skip-ext-form-submit]

Arguments: 1. The name of the existing model (as plural)
					 2. A space-separated list of controller actions

Options: 1. [--skip-ext-index-nav] = Skip extended index navigation functionality
         2. [--skip-ext-form-submit] = Skip extend form submission functionality

Description:
	
	*Controller
		**Adds functionality to support pagination for the index page if extended index navigation was selected.
		**Creates any of the normal REST actions that were passed to the generator.
		**Adds a method to handle strong params. _This should be reviewed to make sure that all of the params that are allowed, should be allowed_.

	*Application Controller
		**Includes concerns ExtFormSubmit and ExtIndexNav depending on configuration

	
	*Concerns
		**installs ext_index_nav.rb if extended index navigation selected
		**installs ext_form_submit.rb if extended form submission selected

	*Routes
		*Adds a resource for the model specified. _This may be an issue if the routes file already contains entries for the resource_

	*Extended index navigation (optional):
		**Generates an index view file for the model specified containing columns with headers for all fields not generated automatically by rails (Everything but id, created_at and updated_at). Certain keywords are given priority when found in the field names which makes them show up before others (eg. name, email)
		**Generates pagination functionality for the index page
		**Adds some styling to the index page
	
	*Extended form submission (optional):
		**Generates a form partial which is utilized by both the new and edit views for the model specified.
		**The form will have input labels and input fields of the proper type prioritized the same way as the index columns
		**The form has two button. 
			***One button performs the "normal" action of saving and redirecting to the list of resources.
			***The other button Saves and reloads the current page allowing the user to add multiple items without having to go back to the index page each time.
		**Adds some styling to the form
		**Adds functionality to display flash messages and validation errors.

	*Assets
		**Javascript
			***Installs ext_index_nav.js if extended index navigation is selected.
			***Requires jquery in application.js
		**Stylesheets
			***Installs controller_scaffolding.css.scss if either extended index navigation or extended form submission are selected


This project rocks and uses MIT-LICENSE.