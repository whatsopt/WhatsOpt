class AddDriverToOperations < ActiveRecord::Migration[5.2]
  def change
    add_column :operations, :driver, :string, default:"runonce"
  end
end
