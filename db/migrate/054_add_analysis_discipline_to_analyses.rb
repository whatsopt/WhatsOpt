class AddAnalysisDisciplineToAnalyses < ActiveRecord::Migration[5.2]
  def change
    add_column :analyses, :analysis_discipline_id, :integer
    add_index :analyses, :analysis_discipline_id
  end
end
