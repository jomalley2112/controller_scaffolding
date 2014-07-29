require 'controller_scaffolding/app/helpers/controller_scaffolding_helper'
module ControllerScaffolding
  class Railtie < Rails::Railtie
    initializer "controller_scaffolding.helper" do
      ActionView::Base.send :include, ControllerScaffoldingHelper
    end
  end
end