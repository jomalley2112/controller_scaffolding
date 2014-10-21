module ControllerScaffolding
	require "haml-rails"
	require "will_paginate"
	require 'jquery-rails'
	require 'controller_scaffolding/add_generator' if defined?(Rails)
	require 'controller_scaffolding/railtie' if defined?(Rails)
	require 'sql_search_n_sort'
	require 'hot_date_rails'
end
