class RenameMda < ActiveRecord::Migration[5.1]
  def change
    rename_table :multi_disciplinary_analyses, :analyses
    rename_column :disciplines, :multi_disciplinary_analysis_id, :analysis_id
  end
end
