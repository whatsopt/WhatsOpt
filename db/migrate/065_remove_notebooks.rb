class RemoveNotebooks < ActiveRecord::Migration[6.0]
  def up
    drop_table :notebooks
  end
end
