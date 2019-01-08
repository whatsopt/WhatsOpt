class ChangeFieldsToBeTextInParameters < ActiveRecord::Migration[5.2]
  def up
    change_column :parameters, :init, :text, default: ""
    change_column :parameters, :lower, :text, default: ""
    change_column :parameters, :upper, :text, default: ""
  end

  def down
    change_column :parameters, :init, :string, default: ""
    change_column :parameters, :lower, :string, default: ""
    change_column :parameters, :upper, :string, default: ""
  end
end
