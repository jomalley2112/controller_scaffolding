require 'generators/controller_generator_base'

module Haml
  module Generators
  	class ControllerScaffoldingGenerator < ::Generators::ControllerGeneratorBase

      source_paths << File.expand_path('../../../../templates/haml/controller', __FILE__)
      
      protected
      def handler
        :haml
      end
      
    end
  end
end
