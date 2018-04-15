class CreateOperations < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:parameters, :lower, from: nil, to: "")
    change_column_default(:parameters, :upper, from: nil, to: "")
    create_table :operations do |t|
      t.integer :analysis_id
      t.string  :name
    end
  end
end
