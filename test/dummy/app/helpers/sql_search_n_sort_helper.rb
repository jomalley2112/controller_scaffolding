module SqlSearchNSortHelper

	#Should only be used for forms performing a GET
	def hide_current_params(*suppress)
		return "" if request.query_parameters.empty?
		request.query_parameters.reject { |k, v| suppress.include?(k) }.map do |k, v|
			hidden_field_tag(k, v)
		end.join("\n")
	end

end