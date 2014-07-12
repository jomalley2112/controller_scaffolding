module ControllerScaffolding
  class AddGenerator < Rails::Railtie
  	generators do
	    require "generators/controller/controller_scaffolding_generator"
	    require "generators/haml/controller/controller_scaffolding_generator"
	  end
  end
end