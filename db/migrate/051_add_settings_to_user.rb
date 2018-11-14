class AddSettingsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :settings, :text
  end
end
