class CreateNotebooks < ActiveRecord::Migration[5.0]
  def change
    create_table :notebooks do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
