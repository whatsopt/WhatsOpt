class AddSuccessToOperations < ActiveRecord::Migration[5.2]
  def change
    add_column :operations, :success, :text
  end
end
