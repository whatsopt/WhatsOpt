class AddKindToDisciplines < ActiveRecord::Migration[5.1]
  def change
    add_column :disciplines, :kind, :string
  end
end
