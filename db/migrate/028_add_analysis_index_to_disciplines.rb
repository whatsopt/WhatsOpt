class AddAnalysisIndexToDisciplines < ActiveRecord::Migration[5.1]
  def change
    add_index :disciplines, :analysis_id
  end
end
