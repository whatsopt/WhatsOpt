class ChangeCaseValuesToLongText < ActiveRecord::Migration[6.0]
  def up
    change_column :cases, :values, :longtext
  end

  def down
    change_column :cases, :values, :text
  end
end
