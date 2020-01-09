class AddTimestampsToOperations < ActiveRecord::Migration[6.0]
  def change
    add_column :operations, :created_at, :datetime
    add_column :operations, :updated_at, :datetime
  end
end
