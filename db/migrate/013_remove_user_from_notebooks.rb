class RemoveUserFromNotebooks < ActiveRecord::Migration[5.1]
  def change
    remove_column :notebooks, :user_id, :string
  end
end
