class AddRoleToConnections < ActiveRecord::Migration[5.1]
  def change
    add_column :connections, :role, :string, default:""
  end
end
