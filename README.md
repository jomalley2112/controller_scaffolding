# ControllerScaffolding #

[![Gem Version](https://badge.fury.io/rb/controller_scaffolding.svg)](http://badge.fury.io/rb/controller_scaffolding)

#### Description ####
The generator acts somewhat like scaffolding, but you must specify an *existing* model and pass in any of the RESTful actions you are interested in (or no actions if you want all of them). With no options passed in except for the template engine (only Haml for now) it generates index pages with search/sort* functionality, basic pagination, and displays flash messages and validation errors. It also adds some styling for the index page and the new/edit form which makes it a bit easier on the eyes until you have a chance to add your own styling.

\* https://github.com/jomalley2112/sql_search_n_sort


#### Index page ####
![Index](/readme_assets/index_ss.png?raw=true "Index")
---

#### Create/Edit page ####
![Form](/readme_assets/form_ss.png?raw=true "Form")
---

Add the following line to your project's Gemfile `gem 'controller_scaffolding'`
and then run `bundle install`


#### Usage ####
```bash
$ rails g|d controller_scaffolding users index new create edit update destroy --template-engine=haml
[--skip-ext-index-nav] [--skip-ext-form-submit] [--skip-assets] [--skip-test-framework] [--skip-helper] [--quiet] [--force] [--skip-search-sort]
```

*Note: You must restart Rails after running this generator*

#### Arguments ####
1. The name of the existing model (as plural)  
2. A space-separated list of controller actions. If none are specified it will act as if *all* RESTful actions were specified. 

#### Options ####
| Option                 | Description                                            | Optional?
| ---------------------- | ------------------------------------------------------ | ---------- |
| --template-engine=haml | Use Haml for template engine - REQUIRED                | no         |
| --skip-ext-index-nav   | Do not include extended index navigation functionality | yes        |
| --skip-ext-form-submit | Do not include extended form submission functionality  | yes        |
| --skip-assets          | Do not create assets                                   | yes        |
| --skip-test-framework  | Do not create test files                               | yes        |
| --skip-helper          | Do not create helper file                              | yes        |
| --quiet                | Suppress info messages                                 | yes        |
| --force                | Overwrite files without prompting                      | yes        |
| --skip-search-sort     | Do not include search or sort functionality            | yes        |

### Description of generator actions ###
	
#### Controller ####
* Adds functionality to support pagination for the index page if extended index navigation was  selected.
* Creates any of the normal REST actions that were passed to the generator. These actions will have built-in functionality that handles success and validation error messages.
* Adds a method to handle strong params. *This should be reviewed to make sure that all of the  params that are allowed, should be allowed*.

#### Application Controller ####
* Includes concerns ExtFormSubmit and ExtIndexNav depending on configuration


#### Concerns ####
* installs ext_index_nav.rb if extended index navigation selected
* installs ext_form_submit.rb if extended form submission selected

#### Routes ####
* Adds a resources line for the model specified. *This may be an issue if the routes file already contains  entries for the resource*

#### Extended index navigation (optional) ####
* Generates an index view file for the model specified containing columns with headers for all  fields not generated automatically by rails (Everything but id, created_at and updated_at). Certain  keywords are given priority when found in the field names which makes them show up before others in the views (eg. name, email)
* Generates pagination functionality for the index page. Default items per page can be set by editing the `@per_page` variable in `app/controllers/concerns/ext_index_nav.rb`
* Adds some styling to the index page

#### Extended form submission (optional) ####
* Generates a form partial which is utilized by both the new and edit views for the model specified.
* The form will have input labels and input fields of the proper type prioritized the same way as  the index columns
* The form has two buttons. 
	* One button performs the "normal" action of saving and redirecting to the list of resources.
	* The other button Saves and reloads the current page allowing the user to add multiple items  without having to go back to the index page each time.
* Adds functionality to display flash messages and validation errors.
* Adds some styling to the form


#### Assets ####
* Javascript
	* Installs ext_index_nav.js if extended index navigation is selected.
	* Requires jquery and jquery_ujs in application.js
* Stylesheets
	* Installs controller_scaffolding.css.scss if either extended index navigation or extended form  submission are selected

#### Search and Sort ####
* see README.md at https://github.com/jomalley2112/sql_search_n_sort

### Testing ###
* Generator tests: run `rake test` from the root directory.
* Integration test specs: run `rspec spec` from 'test/dummy'  

### Gem dependencies ###
#### Dependencies ####
- 'rails', '~> 4.1'
- 'will_paginate'
- 'haml-rails'
- 'sass-rails', '~> 4.0.3'
- 'jquery-rails'
- 'sql_search_n_sort', '=1.15'

#### Development Environment Dependencies ####
- "sqlite3"
- "rspec-rails"
- "capybara"
- "selenium-webdriver"
- "factory_girl_rails"
- "database_cleaner"

#### TODO ####
- See if we can support case where existing model has been removed after generator has been run and then the user decides to uninstall (revoke) controller_scaffolding.
- Do something with template engine hook so Haml doesn't need to be specified in the generator call
	- Add support for Erb
- Add search results message like "9 Results match 'you search string'"
- Nail down versions for dependencies

