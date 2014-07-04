module ExtIndexNav
  
  def setup_pagination(obj_class=controller_name.classify.constantize)
  	@page = params[:page] || 1
  	
  	case params[:per_page]
  	when nil
  		@per_page = 15
  	when "All"
  		@per_page = obj_class.count
  		@selected_val = "All"
  	else
  		@per_page = params[:per_page]
  	end
  end

  

end