#CONTROLLER GENERATOR
#Usage: $rails g controller NonScaffThings index new create edit update destroy --skip-ext-index-nav --skip-ext-form-submit


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

    class ControllerGenerator < NamedBase # :nodoc:
      #TODO...Not sure if these are neccessary
      gem 'will_paginate'
      gem 'haml-rails'

      argument :actions, type: :array, default: [], banner: "action action"
      class_option :ext_index_nav, :type => :boolean, :default => true, :desc => "Include extended index page features."
      class_option :ext_form_submit, :type => :boolean, :default => true, :desc => "Include extended form submission features."      
      check_class_collision suffix: "Controller"

      def create_controller_file
        template 'controller.rb', File.join('app/controllers', class_path, "#{file_name}_controller.rb")
      end

      def add_routes
        #TODO Handle nested resources
        route "resources :#{plural_table_name.to_sym}"
      end

      hook_for :template_engine, :test_framework, :helper, :assets

      private

        # def generate_routing_code(action)
        #   depth = class_path.length
        #   namespace_ladder = class_path.each_with_index.map do |ns, i|
        #     indent("namespace :#{ns} do\n", i * 2)
        #   end.join
        #   route = indent(%{get '#{file_name}/#{action}'\n}, depth * 2)
        #   end_ladder = (1..depth).reverse_each.map do |i|
        #     indent("end\n", i * 2)
        #   end.join
        #  namespace_ladder + route + end_ladder
        # end

        def generate_action_code(action, ext_index=true, ext_form_submit=true)
          case action
            when "index"
              if ext_index
                %Q`setup_pagination
                @#{plural_table_name} = #{class_name.singularize}.all
                  .paginate(per_page: @per_page, page: @page)`
              else
                %Q`@#{plural_table_name} = #{class_name.singularize}.all`
              end
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
      #flash_alert(@#{table_name.singularize}) #Should add this to the generators
      render :edit
    end`
            when "create"
              redir_call = ext_form_submit ? "redir_url" : "new_#{table_name.singularize}_url(@#{table_name.singularize})"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.new(#{table_name.singularize}_params)
    if @#{table_name.singularize}.save
      flash[:success] = "Created #{table_name.singularize.humanize} successfully"
      redirect_to #{redir_call}
    else
      #flash_alert(@#{table_name.singularize}) #Should add this functionality to the generators too
      render :new
    end`
            when "destroy"
              %Q`@#{table_name.singularize} = #{class_name.singularize}.find(params[:id])
    @#{table_name.singularize}.destroy`
          end
        end

        def generate_strong_params_def
          %Q`def #{table_name.singularize}_params
    params.required(:#{table_name.singularize}).permit(#{Rails::Generators::attr_cols(table_name).map { |col| col.name.to_sym}})
  end`
        end

    end
    
  end
end
