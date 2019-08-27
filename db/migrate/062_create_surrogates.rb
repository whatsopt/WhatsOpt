class CreateSurrogates < ActiveRecord::Migration[5.2]
  def change
    create_table :surrogates do |t|
      t.references :meta_model
      t.references :variable
      t.integer :coord_index 
      t.string :kind
      t.string :status
    end
  end
end
