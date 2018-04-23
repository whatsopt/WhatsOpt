class AddRoleToVariables < ActiveRecord::Migration[5.1]
  def change
    add_column :variables, :role, :string
  end
end
