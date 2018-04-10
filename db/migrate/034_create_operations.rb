class CreateOperations < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:parameter, :lower, "")
    change_column_default(:parameter, :upper, "")
    create_table :operations do |t|
      t.integer :analysis_id
      t.string  :name
    end
  end
end
