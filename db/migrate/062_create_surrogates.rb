class CreateSurrogates < ActiveRecord::Migration[5.2]
  def change
    create_table :surrogates do |t|
      t.references :meta_model, foreign_key: true
      t.references :variable, foreign_key: true
      t.integer :coord_index 
      t.string :kind
      t.string :status
    end
  end
end
