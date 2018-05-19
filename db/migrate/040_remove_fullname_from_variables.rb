class RemoveFullnameFromVariables < ActiveRecord::Migration[5.1]
  def change
    remove_column :variables, :fullname, :string
  end
end
