class CreatePeople < ActiveRecord::Migration
  def change
    create_table :temp_people do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :title
      t.datetime :dob
      t.boolean :is_manager

      t.timestamps
    end
  end
end
