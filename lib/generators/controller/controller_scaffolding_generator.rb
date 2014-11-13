#CONTROLLER GENERATOR
#To Teardown manually:
# rails d controller_scaffolding people index new create edit update destroy custom_action --template-engine=haml

# require 'rails/generators/generated_attribute'

module Rails
  module Generators
    
    class ControllerScaffoldingGenerator < Rails::Generators::NamedBase
      argument :actions, type: :array, default: [], banner: "action action"
      class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
      class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      
      class_option :search_sort, :type => :boolean, :default => true, :desc => "Add search and sort functionality to index page."      
      check_class_collision suffix: "Controller"
      
      #Note: This needs to be set Outside of any methods
      source_paths << [File.expand_path('../../../templates/rails/controller', __FILE__)]

      def setup_actions
        @restful_actions = %w(index new create edit update destroy)
        @actions = actions.nil? || actions.empty? ? @restful_actions : actions
      end

      def check_for_model #TODO: only do if behavior = :invoke maybe?
        #this rescue has only been smoke-tested. can't find a way to unit test
        begin
        table_name.classify.constantize #throws runtime if model doesn't exist
        rescue NameError
          raise Thor::Error, 
            "Cannot run controller scaffold for model (#{table_name.classify}) that doesn't yet exist."
        end
      end

      def create_controller_file
        template 'controller.rb', File.join('app/controllers', class_path, "#{file_name}_controller.rb")
      end

      def add_resources_route
        #TODO Handle nested resources here (look at namespace_ladder in scaffold generators)
        route "resources :#{plural_table_name.to_sym}"
      end

      def add_restless_routes
        #TODO: make this a little more intelligent so if an action specified to the
        # generator is Non-RESTful just add a simple "get" route for it BEFORE the resources route
        #like: get '#{@contr_name}/an_action', to: '#{@contr_name}#an_action'
        @actions.reject { |a| @restful_actions.include?(a) }
          .each do |action|
            route "get '#{file_name}/#{action}', to: '#{file_name}##{action}'"
          end
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
        def generate_action_code(action)
          case action
            when "index"
              options.ext_index_nav? ? draw_index_action : draw_get_items_for_index
            when "edit"
              %Q`@#{singular_table_name} = #{actual_class_name}.find(params[:id])`
            when "new"
              %Q`@#{singular_table_name} = #{actual_class_name}.new`
            when "update"
              redir_call = options.ext_form_submit? ? "redir_url" : "edit_#{singular_table_name}_url(@#{singular_table_name})"
              %Q`@#{singular_table_name} = #{actual_class_name}.find(params[:id])
    if @#{singular_table_name}.update_attributes(#{singular_table_name}_params)
      flash[:success] = "Updated #{human_model_name} successfully"
      redirect_to #{redir_call}
    else
      flash_alert(@#{singular_table_name})
      render :edit
    end`
            when "create"
              redir_call = options.ext_form_submit? ? "redir_url" : "new_#{singular_table_name}_url(@#{singular_table_name})"
              %Q`@#{singular_table_name} = #{actual_class_name}.new(#{singular_table_name}_params)
    if @#{singular_table_name}.save
      flash[:success] = "Created #{human_model_name} successfully"
      redirect_to #{redir_call}
    else
      flash_alert(@#{singular_table_name})
      render :new
    end`
            when "destroy"
              %Q`@#{singular_table_name} = #{actual_class_name}.find(params[:id])
    if @#{singular_table_name}.destroy
      flash[:success] = "Deleted #{human_model_name} successfully"
    else
      flash[:error] = "Unable to delete #{human_model_name}"
    end
    redirect_to #{plural_table_name}_url`
          end
        end

      def generate_strong_params_def
        %Q`\tdef #{singular_table_name}_params
      params.required(:#{singular_table_name}).permit(#{GeneratorUtils::attr_cols(table_name).map { |col| col.name.to_sym}})
    end`
      end

      def draw_index_action
          %Q`setup_pagination
    #{draw_get_items_for_index}
      .paginate(per_page: @per_page, page: @page)`
      end

      def draw_get_items_for_index
        if options.search_sort?
    "@#{plural_table_name} = #{actual_class_name}.sql_search(params[:search_for]).sql_sort(@sort_by, @sort_dir)"
        else
    "@#{plural_table_name} = #{actual_class_name}.all"
        end
      end

      #This shouldn't be necessary, but class_name returns a plural
      def actual_class_name
        class_name.singularize
      end

      def human_model_name
        singular_table_name.humanize        
      end

    end
  end

end
