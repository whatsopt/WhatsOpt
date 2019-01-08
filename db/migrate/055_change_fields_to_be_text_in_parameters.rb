class ChangeFieldsToBeTextInParameters < ActiveRecord::Migration[5.2]
  def up
    change_column :parameters, :init, :text, default: nil
    change_column :parameters, :lower, :text, default: nil
    change_column :parameters, :upper, :text, default: nil
  end

  def down
    change_column :parameters, :init, :string, default: ""
    change_column :parameters, :lower, :string, default: ""
    change_column :parameters, :upper, :string, default: ""
  end
end
