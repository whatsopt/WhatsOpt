class CreateParameters < ActiveRecord::Migration[5.1]
  def change
    create_table :parameters do |t|
      t.float :init
      t.float :lower
      t.float :upper
      t.integer :variable_id

      t.timestamps
    end
  end
end
