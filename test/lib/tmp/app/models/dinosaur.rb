class Dinosaur < ActiveRecord::Base

	sql_searchable :name  #, :age, :good_dino
end
