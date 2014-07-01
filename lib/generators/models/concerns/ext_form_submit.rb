module ExtFormSubmit
	def redir_url()
    if params[:commit] =~ /reload/i
      :back
    else
      eval("#{params[:controller]}_url")
    end
  end

  def flash_alert(obj)
    err_str = view_context.render_for_controller("validation_errors", {:obj => obj})
    msg = ("Unable to #{action_name} #{obj.class} for the following" + 
      " " + view_context.pluralize(obj.errors.full_messages.length, "reason") + 
      ":#{err_str}") unless obj.errors.messages.size < 1
    flash.now[:error] = msg.html_safe
  end
end