require 'rails/generators/generated_attribute'

module GeneratorUtils
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
    
  def self.attr_cols(table_name)
    #return an array of the columns we are interested in allowing the user to change...
    # as GeneratedAttribute objects
    acs = table_name.classify.constantize.columns
      .reject{ |col| RAILS_ADDED_COLS.include?(col.name) }
      .sort(&ATTR_SORT_PROC)
      .map { |ac| Rails::Generators::GeneratedAttribute.new(ac.name, ac.type)}
  end
  
end