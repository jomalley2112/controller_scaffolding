class Dinosaur < ActiveRecord::Base

	extend SqlSearchableSortable

	sql_searchable :name  #, :age, :good_dino

	sql_sortable :name, :age, :good_dino
end
