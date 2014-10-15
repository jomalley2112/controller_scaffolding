class CreateUnsearchables < ActiveRecord::Migration
  def change
    create_table :unsearchables do |t|
      t.date :dt
      t.boolean :bool

      t.timestamps
    end
  end
end
