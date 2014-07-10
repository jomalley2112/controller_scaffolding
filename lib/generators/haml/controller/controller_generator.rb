#TEMPLATE GENERATOR & FILE COPIER
# $ rails g controller NonScaffThings index new create edit update destroy [--force] [--skip-ext-index-nav]  [--skip-ext-form-submit]

require 'rails/generators/erb/controller/controller_generator'
require 'rails/generators/erb/scaffold/scaffold_generator'

module Haml
  module Generators
  	class ControllerGenerator < Erb::Generators::ControllerGenerator #ScaffoldGenerator
      argument :actions, type: :array, default: [], banner: "action action"
      class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
      class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      
      
      source_paths << File.expand_path('../../../../templates/haml/controller', __FILE__)
      def copy_view_files #do NOT change the name of this method 
                          # it must be overriding an existing one in a parent class
        base_path = File.join("app/views", class_path, file_name)
        empty_directory base_path
        @attr_cols = ::Rails::Generators::attr_cols(table_name)
        (actions - %w(create update destroy)).each do |action|
          @action = action
          formats.each do |format|
            @path = File.join(base_path, filename_with_extensions(action, format))
            set_template(@action, @path)
          end
        end
      end

      def gen_form_partial
        #Create _form partial?
        base_path = File.join("app/views", class_path, file_name)
        unless (actions & %w(edit new)).empty? #Remember that "&" is intersect
          @path = File.join(base_path, filename_with_extensions("_form", format))
          set_template("_form", @path) 
        end
      end

      #TODO; I couldn't get the tests to work with relative paths being passed to the 
      # inject_into_file calls...it wants to make them relative to the test's destination directory

      def handle_ext_index
        #Extended index functionality?
        if options.ext_index_nav?
          copy_controller_concern("ext_index_nav.rb")
          inject_into_file "#{::Rails.root.to_s}/app/controllers/application_controller.rb", 
                after: "class ApplicationController < ActionController::Base\n" do
                  "\ninclude ExtIndexNav\n\n"
                end
          copy_partial("_pagination")
          add_pagination_to_locale_file
          copy_ext_index_js
          inject_into_file "#{::Rails.root.to_s}/app/assets/javascripts/application.js",
            before: "\n//= require_tree ." do
              "\n//= require jquery"
            end
        end
      end
        
      def handle_ext_form
        #extended form submission functionality?
        if options.ext_form_submit?
          copy_controller_concern("ext_form_submit.rb")

          inject_into_file "#{::Rails.root.to_s}/app/controllers/application_controller.rb", 
                after: "class ApplicationController < ActionController::Base\n" do
                  "\ninclude ExtFormSubmit\n\n"
                end
          copy_partial("_flash_messages")
          inject_into_file "#{::Rails.root.to_s}/app/views/layouts/application.html.erb", 
                before: "<%= yield %>\n" do
                  "\n<%= render 'flash_messages' %>\n"
                end
          copy_partial("_validation_errors")
          inject_into_file "#{::Rails.root.to_s}/app/helpers/application_helper.rb",
                after: "module ApplicationHelper\n" do
                  "\ndef render_for_controller(partial, local_vars)
        render(:partial => partial, :locals => local_vars).html_safe
      end\n"
                end
        end
      end
        
      def copy_stylesheet
        if options.ext_form_submit? || options.ext_index_nav?
          source_paths << File.expand_path('../../../../generators/assets/stylesheets', __FILE__)
          base_path = "app/assets/stylesheets"
          path = File.join(base_path, 'controller_scaffolding.css.scss')
          copy_file('controller_scaffolding.css.scss', path) if file_action(path)
        end
      end

      
#================================= P R O T E C T E D =================================
      protected
			def handler
        :haml
      end
#================================= P R I V A T E =====================================
      private

      def set_template(action, path)
      	template filename_with_extensions(action.to_sym, format), path
      	rescue Thor::Error => e 
          say("Falling back to the 'view.html.haml' template because #{action}.html.haml doesn't exist", 
              :magenta) unless options.quiet?
      		template filename_with_extensions(:view, format), @path
      end

      def copy_partial(file)
        source_paths << File.expand_path('../partials', __FILE__)
        base_path = "app/views/application"
        path = File.join(base_path, filename_with_extensions( file, format))
        copy_file(filename_with_extensions(file, format), path) if file_action(path)
      end

      def copy_controller_concern(file_w_ext)
        source_paths << File.expand_path('../../../../generators/controller/concerns', __FILE__)
        base_path = "app/controllers/concerns"
        path = File.join(base_path, file_w_ext)
        copy_file(file_w_ext, path) if file_action(path)
      end

      def copy_ext_index_js
        source_paths << File.expand_path('../../../../generators/assets/javascripts', __FILE__)
        base_path = "app/assets/javascripts"
        path = File.join(base_path, 'ext_index_nav.js')
        copy_file('ext_index_nav.js', path) if file_action(path)
      end

      def add_pagination_to_locale_file
        inject_into_file "#{::Rails.root.to_s}/config/locales/en.yml", 
          after: "\nen:\n" do
%Q{\n
  will_paginate:
    models:
      people:
        zero:  People
        one:   Person
        other: People
    page_entries_info:
      multi_page_html: "Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b> %{model}"
      single_page_html:
        zero:  "No %{model} found"
        one:   "Displaying <b>1</b> %{model}"
        other: "Displaying <b>all&nbsp;%{count}</b> %{model}"
}
          end
      end

      def file_action(path)
        return true if options.force?
        if behavior == :revoke
          verb = "Remove"
        elsif File.exists?(path)
          verb = "Overwrite existing"  
        else
          return true
        end
        return yes?("#{verb} shared file #{path}? (y or n)", :yellow)
      end

      def inc_link?(name)
        actions.include?(name)
      end
    end
  end
end
