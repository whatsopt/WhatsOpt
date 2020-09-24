class AddDeactivatedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :deactivated, :boolean
  end
end
