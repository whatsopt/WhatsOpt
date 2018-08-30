class CreateOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :options do |t|
      t.string :name
      t.string :value
      t.integer :operation_id
    end
    
    add_index :options, :operation_id
  end
end
