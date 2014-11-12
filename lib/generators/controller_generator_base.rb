module Generators
  require 'rails/generators/erb/controller/controller_generator'
  require 'rails/generators/erb/scaffold/scaffold_generator'
  class ControllerGeneratorBase < Erb::Generators::ControllerGenerator
    
    argument :actions, type: :array, default: [], banner: "action action"
    class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
    class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      
    class_option :search_sort, :type => :boolean, :default => true, :desc => "Add search and sort functionality to index page."
    class_option :datepicker, :type => :boolean, :default => true, :desc => "Use datepicker for date/time fields."

    
    #This method seems to always get run first
    def copy_view_files #do NOT change the name of this method 
                        # it must be overriding an existing one in a parent class
      base_path = File.join("app/views", class_path, file_name)
      empty_directory base_path
      @actions = actions.nil? || actions.empty? ? %w(index new create edit update destroy) : actions
      #binding.pry
      @attr_cols = ::Rails::Generators::attr_cols(table_name)
      @col_count = @attr_cols.count
      @col_count += 1 if @actions.include?("edit")
      @col_count += 1 if @actions.include?("destroy")
      @search_sort = options.search_sort?
      (@actions - %w(create update destroy)).each do |action|
        @action = action
        formats.each do |format|
          @path = File.join(base_path, filename_with_extensions(action, format))
          set_template(@action, @path)
        end
      end
    end

    def gen_form_partial
      base_path = File.join("app/views", class_path, file_name)
      unless (@actions & %w(edit new)).empty? #Remember that "&" is Array#intersect
        @path = File.join(base_path, filename_with_extensions("_form", format))
        set_template("_form", @path) 
      end
    end

    def handle_ext_index
      if options.ext_index_nav?
        copy_controller_concern("ext_index_nav.rb")
        inject_into_file "app/controllers/application_controller.rb", 
              after: "class ApplicationController < ActionController::Base\n" do
                "\n\tinclude ExtIndexNav\n"
              end
        copy_partial("_pagination")
        add_pagination_to_locale_file
        copy_ext_index_js
        inc_jquery_scripts
      end
    end
      
    def handle_ext_form
      if options.ext_form_submit?
        copy_controller_concern("ext_form_submit.rb")

        inject_into_file "app/controllers/application_controller.rb", 
              after: "class ApplicationController < ActionController::Base\n" do
                "\n\tinclude ExtFormSubmit\n"
              end
        copy_partial("_flash_messages")
        inject_into_file "app/views/layouts/application.html.erb", 
              before: "<%= yield %>\n" do
                "\n<%= render 'flash_messages' %>\n"
              end
        copy_partial("_validation_errors")
      end
    end

    def handle_datepicker
      if options.datepicker?
        inc_jquery_scripts
        inject_into_file "app/assets/javascripts/application.js",
          after: "\n//= require_tree ." do
            "\n//= require hot_date_rails"
          end
        inject_into_file "app/assets/stylesheets/application.css",
          before: "\n *= require_tree ." do
            "\n *= require hot_date_rails"
          end
      end
    end
      
    def copy_stylesheet
      if options.ext_form_submit? || options.ext_index_nav?
        source_paths << File.expand_path('../../../lib/generators/assets/stylesheets', __FILE__)
        base_path = "app/assets/stylesheets"
        path = File.join(base_path, 'controller_scaffolding.css.scss')
        copy_file('controller_scaffolding.css.scss', path) if file_action(path)
      end
    end

    #This is the code that add SnS functionality to the model specified in the controller generator
    def handle_search_n_sort
      if @search_sort
        inject_into_file "app/models/#{table_name.singularize}.rb",
          before: /^end/ do
            "\n\textend SqlSearchableSortable\n"
          end
        inject_into_file "app/models/#{table_name.singularize}.rb",
          before: /^end/ do
            "\n\tsql_searchable #{searchable_cols_as_symbols}\n" 
          end
        inject_into_file "app/models/#{table_name.singularize}.rb",
          before: /^end/ do
            "\n\tsql_sortable #{cols_to_symbols}\n"
          end
      end

    end

    def print_warnings
      if @unsearchable_model && behavior == :invoke && !options.quiet?
        warn("WARNING: Model #{table_name.classify} is extending SqlSearchableSortable," \
          " but doesn't have any searchable attributes at this point.") 
      end
    end      
  #================================= P R I V A T E =====================================
    private

    def inc_jquery_scripts
      inject_into_file "app/assets/javascripts/application.js",
        before: "\n//= require_tree ." do
          "\n//= require jquery\n//= require jquery_ujs"
        end unless @injected_jquery_ujs #shouldn't allow duplicate text, but just to be safe
      @injected_jquery_ujs = true
    end

    def searchable_cols_as_symbols
      retval = @attr_cols.select{ |col| [:string, :text].include? col.type}
        .map { |col| col.name.to_sym }.to_s.gsub(/\[(.*)\]/, '\1')
      @unsearchable_model = true if retval.empty?
      return retval
    end

    def cols_to_symbols
      # going from [:col1, :col2, :col3] to ":col1, :col2, :col3"
      #ugly, but I can't find another way to keep the symbols and lose the brackets
      @attr_cols.map { |col| col.name.to_sym }.to_s.gsub(/\[(.*)\]/, '\1')
    end

    def set_template(action, path)
    	template filename_with_extensions(action.to_sym, format), path
    	rescue Thor::Error => e 
        say("Falling back to the 'view.html.#{handler}' template because #{action}.html.#{handler} doesn't exist", 
            :magenta) unless options.quiet? || behavior == :revoke
    		template filename_with_extensions(:view, format), @path
    end

    def copy_partial(file)
      source_paths << File.expand_path("../../../lib/generators/#{handler}/controller/partials", __FILE__)
      base_path = "app/views/application"
      path = File.join(base_path, filename_with_extensions( file, format))
      copy_file(filename_with_extensions(file, format), path) if file_action(path)
    end

    def copy_controller_concern(file_w_ext)
      source_paths << File.expand_path('../../../lib/generators/controller/concerns', __FILE__)
      base_path = "app/controllers/concerns"
      path = File.join(base_path, file_w_ext)
      copy_file(file_w_ext, path) if file_action(path)
    end

    def copy_ext_index_js
      source_paths << File.expand_path('../../../lib/generators/assets/javascripts', __FILE__)
      base_path = "app/assets/javascripts"
      path = File.join(base_path, 'ext_index_nav.js')
      copy_file('ext_index_nav.js', path) if file_action(path)
    end

    def add_pagination_to_locale_file
      #TODO: Could put some kind of logic in here when revoking that removes some lines
      # from the locale file, but it shouldn't hurt anything if we don't
      lang = I18n.locale.to_s
      locale_config = YAML.load_file("#{destination_root}/config/locales/#{lang}.yml")
      locale_config[I18n.locale.to_s] = {} unless locale_config[lang]
      lc_wp = locale_config[I18n.locale.to_s]['will_paginate'] ||=
        locale_config[I18n.locale.to_s]['will_paginate'] = {}
      wp_models = lc_wp['models'] || lc_wp['models'] = {}
      curr_model = wp_models[table_name] || 
        wp_models[table_name] = { "zero"=>table_name.humanize, 
                                  "one"=>file_name.singularize.humanize, 
                                  "other"=>table_name.humanize }
      wp_pei = lc_wp['page_entries_info'] || lc_wp['page_entries_info'] = {}
      pei_mph = wp_pei['multi_page_html'] || wp_pei['multi_page_html'] = 
        "Displaying <b>%{from}&nbsp;-&nbsp;%{to}</b> of <b>%{count}</b> %{model}"

      pei_sph = wp_pei['single_page_html'] || wp_pei['single_page_html'] = {}
      pei_sph['zero'] || pei_sph['zero'] = "No %{model} found"
      pei_sph['one'] || pei_sph['one'] = "Displaying <b>1</b> %{model}"
      pei_sph['other'] || pei_sph['other'] = "Displaying <b>all&nbsp;%{count}</b> %{model}"
      File.open("#{destination_root}/config/locales/#{lang}.yml", "w") { |f| YAML.dump(locale_config, f) }
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
      @actions.include?(name)
    end
  end
end
