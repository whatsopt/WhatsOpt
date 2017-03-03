class CreateDisciplines < ActiveRecord::Migration[5.0]
  def change
    create_table :disciplines do |t|
      t.string :name
      t.integer :multi_disciplinary_analisys_id

      t.timestamps
    end
  end
end
