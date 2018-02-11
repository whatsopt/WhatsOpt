class CreateConnections < ActiveRecord::Migration[5.1]
  def change
    create_table :connections do |t|
      t.integer :from_id
      t.integer :to_id
    end
    add_index :connections, :from_id
    add_index :connections, :to_id
  end
end
