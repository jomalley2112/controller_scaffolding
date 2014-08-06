class CreateDinosaurs < ActiveRecord::Migration
  def change
    create_table :dinosaurs do |t|
      t.string :name
      t.string :age
      t.boolean :good_dino

      t.timestamps
    end
  end
end
