class CreateOperations < ActiveRecord::Migration[5.1]
  def change
    create_table :operations do |t|
      t.integer :analysis_id
      t.string :category
      t.string :category_method
    end
  end
end
