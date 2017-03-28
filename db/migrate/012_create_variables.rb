class CreateVariables < ActiveRecord::Migration[5.0]
  def change
    create_table :variables do |t|
      t.string :name
      t.integer :discipline_id
      t.string :io_mode

      t.timestamps
    end
  end
end
