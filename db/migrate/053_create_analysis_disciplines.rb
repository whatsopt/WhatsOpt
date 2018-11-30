class CreateAnalysisDisciplines < ActiveRecord::Migration[5.2]
  def change
    create_table :analysis_disciplines do |t|
      t.references :discipline, foreign_key: true
    end
  end
end
