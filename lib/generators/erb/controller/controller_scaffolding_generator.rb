require 'generators/controller_generator_base'

module Erb
  module Generators
    class ControllerScaffoldingGenerator < ::Generators::ControllerGeneratorBase
      
      source_paths << File.expand_path('../../../../templates/erb/controller', __FILE__)

      protected
      def handler
        :erb
      end
      
    end
  end
end
