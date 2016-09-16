class AddTreeJsonToStudies < ActiveRecord::Migration[5.0]
  def change
    add_column :studies, :tree_json, :text
  end
end
