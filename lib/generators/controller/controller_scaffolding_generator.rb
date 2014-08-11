#CONTROLLER GENERATOR
#To Teardown manually:
# rails d controller_scaffolding people index new create edit update destroy custom_action --template-engine=haml

require 'rails/generators/generated_attribute'


module Rails
  module Generators
    #####################  Generators module methods  #####################
    RAILS_ADDED_COLS = %w(id created_at updated_at)
    
    #TODO...There has GOT to be a better way to do this (column name gets listed first if it contains the word "name")
    ATTR_SORT_PROC = 
      proc do |a, b|
        if a =~ /name/
          1
        elsif b =~ /name/
          -1
        elsif a =~ /email/
          1
        elsif b =~ /email/
          -1
        else
          0
        end
      end
    
    def attr_cols(table_name)
      #return an array of the columns we are interested in allowing the user to change...
      # as GeneratedAttribute objects
      acs = table_name.classify.constantize.columns
        .reject{ |col| RAILS_ADDED_COLS.include?(col.name) }
        .sort(&ATTR_SORT_PROC)
        .map { |ac| GeneratedAttribute.new(ac.name, ac.type)}
    end
    module_function :attr_cols
    #######################################################################

    class ControllerScaffoldingGenerator < Rails::Generators::NamedBase
      argument :actions, type: :array, default: [], banner: "action action"
      class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
      class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      
      class_option :search_sort, :type => :boolean, :default => true, :desc => "Add search and sort functionality to index page."      
      check_class_collision suffix: "Controller"
      
      #Note: This needs to be set Outside of any methods
      source_paths << [File.expand_path('../../../templates/rails/controller', __FILE__)]

      def setup_actions
        @actions = actions.nil? || actions.empty? ? %w(index new create edit update destroy) : actions
      end

      def check_for_model #TODO: only do if behavior = :invoke maybe?
        begin
        table_name.classify.constantize #throws runtime if model doesn't exist
        rescue
          raise Thor::Error, 
            "Cannot run controller scaffold for model (#{table_name.classify}) that doesn't yet exist."
        end
      end

      def create_controller_file
        template 'controller.rb', File.join('app/controllers', class_path, "#{file_name}_controller.rb")
      end

      def add_routes
        #TODO Handle nested resources here (look at namespace_ladder in scaffold generators)
        route "resources :#{plural_table_name.to_sym}"
      end

      hook_for :template_engine, :assets, :test_framework, :helper
      def run_sns_gen
        #TODO: should see if we can do this with a hook_for as well
        invoke "sql_search_n_sort:install" if options.search_sort?  
      end
      
      #generate "sql_search_n_sort"
#================================ P R I V A T E =================================
      private
        #This method gets called from the controller.rb template
        def generate_action_code(action, ext_index=true, ext_form_submit=true)
          case action
            when "index"
              draw_index_action(true)
            when "edit"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.find(params[:id])`
            when "new"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.new`
            when "update"
              redir_call = ext_form_submit ? "redir_url" : "edit_#{table_name.singularize}_url(@#{table_name.singularize})"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.find(params[:id])
    if @#{table_name.singularize}.update_attributes(#{table_name.singularize}_params)
      flash[:success] = "Updated #{table_name.singularize.humanize} successfully"
      redirect_to #{redir_call}
    else
      flash_alert(@#{table_name.singularize})
      render :edit
    end`
            when "create"
              redir_call = ext_form_submit ? "redir_url" : "new_#{table_name.singularize}_url(@#{table_name.singularize})"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.new(#{table_name.singularize}_params)
    if @#{table_name.singularize}.save
      flash[:success] = "Created #{table_name.singularize.humanize} successfully"
      redirect_to #{redir_call}
    else
      flash_alert(@#{table_name.singularize})
      render :new
    end`
            when "destroy"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.find(params[:id])
    if @#{table_name.singularize}.destroy
      flash[:success] = "Deleted #{table_name.singularize.humanize} successfully"
    else
      flash[:error] = "Unable to delete #{table_name.singularize.humanize}"
    end
    redirect_to #{table_name.pluralize}_url`
          end
        end

      def generate_strong_params_def
        %Q`\tdef #{table_name.singularize}_params
      params.required(:#{table_name.singularize}).permit(#{Rails::Generators::attr_cols(table_name).map { |col| col.name.to_sym}})
    end`
      end

      def draw_index_action(ext_index=true)
        if ext_index
          %Q`setup_pagination
    #{draw_get_items_for_index}
      .paginate(per_page: @per_page, page: @page)`
        else
    draw_get_items_for_index
        end
      end

      def draw_get_items_for_index
        if options.search_sort?
    "@#{plural_table_name} = #{class_name.singularize}.sql_search(params[:search_for]).sql_sort(@sort_by, @sort_dir)"
        else
    "@#{plural_table_name} = #{class_name.singularize}.all"
        end
      end

    end
  end

end
