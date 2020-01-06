class AddDerivedOperationToOperations < ActiveRecord::Migration[6.0]
  def change
    add_column :operations, :base_operation_id, :integer
  end
end
