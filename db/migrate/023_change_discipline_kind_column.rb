class ChangeDisciplineKindColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :disciplines, :kind, :type
  end
end
