#TEMPLATE GENERATOR & FILE COPIER
# $rails g controller NonScaffThings index new create edit update destroy [--skip-ext-index-nav]  [--skip-ext-form-submit]


require 'rails/generators/erb/controller/controller_generator'
require 'rails/generators/erb/scaffold/scaffold_generator'

#require 'generators/controller/controller_generator'
#require 'rails/generators/erb'

module Haml
  module Generators
  	class ControllerGenerator < Erb::Generators::ControllerGenerator #ScaffoldGenerator # # :nodoc:
      argument :actions, type: :array, default: [], banner: "action action"
      class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
      class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      

      def copy_view_files
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

        #Create _form partial?
        unless (actions & %w(edit new)).empty? #Remember that "&" is intersect
          @path = File.join(base_path, filename_with_extensions("_form", format))
          set_template("_form", @path) 
        end
        
        #Extended index functionality?
        if options.ext_index_nav?
          copy_ext_index_concern
          inject_into_file 'app/controllers/application_controller.rb', 
                after: "class ApplicationController < ActionController::Base\n" do
                  "\ninclude ExtController\n\n"
                end
          copy_pagination_partial
          append_file 'app/assets/javascripts/application.js', pagination_js_code
          copy_ext_index_stylesheet
        end

        #extended form submissoin functionality?
        if options.ext_form_submit?
          copy_ext_form_submit_concern
          inject_into_file 'app/controllers/application_controller.rb', 
                after: "class ApplicationController < ActionController::Base\n" do
                  "\ninclude ExtFormSubmit\n\n"
                end
          copy_flash_msgs_partial
          inject_into_file 'app/views/layouts/application.html.erb', 
                before: "<%= yield %>\n" do
                  "\n<%= render 'flash_messages' %>\n"
                end
          copy_val_errors_partial
          inject_into_file 'app/helpers/application_helper.rb',
                after: "module ApplicationHelper\n" do
                  "\ndef render_for_controller(partial, local_vars)
        render(:partial => partial, :locals => local_vars).html_safe
      end\n"
            end
        end

      end

      protected
			def handler
        :haml
      end

      private

      def set_template(action, path)
      	template filename_with_extensions(action.to_sym, format), path
      	rescue Thor::Error => e 
      		puts "JOM...falling back to the 'view.html.haml' template because #{action}.html.haml doesn't exist"
      		template filename_with_extensions(:view, format), @path
      end
      def copy_pagination_partial
        source_paths << File.expand_path('../partials', __FILE__)
        base_path = "app/views/application"
        path = File.join(base_path, filename_with_extensions( "_pagination", format))
        copy_file(filename_with_extensions( "_pagination",format), path) if file_action(path)
      end
      def copy_ext_index_concern
        source_paths << File.expand_path('../../../../generators/models/concerns', __FILE__)
        base_path = "app/models/concerns"
        path = File.join(base_path, 'ext_index_nav.rb')
        copy_file('ext_index_nav.rb', path) if file_action(path)
      end

      def copy_ext_index_stylesheet
        source_paths << File.expand_path('../../../../generators/assets/stylesheets', __FILE__)
        base_path = "app/assets/stylesheets"
        path = File.join(base_path, 'ext_index_nav.css.scss')
        copy_file('ext_index_nav.css.scss', path) if file_action(path)
      end

      def copy_ext_form_submit_concern
        source_paths << File.expand_path('../../../../generators/models/concerns', __FILE__)
        base_path = "app/models/concerns"
        path = File.join(base_path, 'ext_form_submit.rb')
        copy_file('ext_form_submit.rb', path) if file_action(path)
      end

      def copy_flash_msgs_partial
        source_paths << File.expand_path('../partials', __FILE__)
        base_path = "app/views/application"
        path = File.join(base_path, filename_with_extensions( "_flash_messages", format))
        copy_file(filename_with_extensions( "_flash_messages",format), path) if file_action(path)
      end

      def copy_val_errors_partial
        source_paths << File.expand_path('../partials', __FILE__)
        base_path = "app/views/application"
        path = File.join(base_path, filename_with_extensions( "_validation_errors", format))
        copy_file(filename_with_extensions( "_validation_errors",format), path) if file_action(path)
      end

      def file_action(path)
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

      #TODO Move this to separate .js file and copy it over and reference it in application.js
      def pagination_js_code
        %Q`function set_per_page(sel) {
    url = updateQueryStringParameter($(location).attr('href'), "per_page", $(sel).val())
    window.location = updateQueryStringParameter(url, "page", "1")
  }
function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}`
      end
        
    end
    
  end
end
