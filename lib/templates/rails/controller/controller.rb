<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= class_name %>Controller < ApplicationController
<% @actions.each do |action| -%>
  def <%= action %>
  	<%= generate_action_code(action) %>
  end
<%= "\n"  -%>
<% end -%>
	private
	<%= generate_strong_params_def %>
end
<% end -%>