class CreateAnalysisDisciplines < ActiveRecord::Migration[5.2]
  def change
    create_table :analysis_disciplines do |t|
      t.references :discipline, foreign_key: true, type: :int
      t.references :analysis, foreign_key: true, type: :int
    end
  end
end
