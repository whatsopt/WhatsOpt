class AddAncestryToAnalyses < ActiveRecord::Migration[5.2]
  def change
    add_column :analyses, :ancestry, :string
    add_index :analyses, :ancestry
  end
end
