class CreateMultiDisciplinaryAnalyses < ActiveRecord::Migration[5.0]
  def change
    create_table :multi_disciplinary_analyses do |t|
      t.string :name

      t.timestamps
    end
  end
end
