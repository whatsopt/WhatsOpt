class CreateMetaModelPrototypes < ActiveRecord::Migration[6.0]
  def change
    create_table :meta_model_prototypes do |t|
      t.integer :meta_model_id
      t.integer :prototype_id
    end
    add_index :meta_model_prototypes, :meta_model_id
    add_index :meta_model_prototypes, :prototype_id
  end
end
