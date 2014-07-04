module ApplicationHelper

def render_for_controller(partial, local_vars)
        render(:partial => partial, :locals => local_vars).html_safe
      end
end
