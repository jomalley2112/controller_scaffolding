module ControllerScaffolding
	require "haml-rails"
	require "will_paginate"
	require 'jquery-rails'
	#require "factory_girl_rails" if Rails.env == 'test'
	require 'controller_scaffolding/add_generator' if defined?(Rails)
	require 'controller_scaffolding/railtie' if defined?(Rails)
	require 'sql_search_n_sort' #The actual gem instead of all the separate files
end
