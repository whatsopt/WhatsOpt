# frozen_string_literal: true

class DropMetamodelAndSurrogateTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :surrogates, if_exists: true
    drop_table :meta_model_prototypes, if_exists: true
    drop_table :meta_models, if_exists: true
  end

  def down
    create_table :meta_models do |t|
      t.timestamps
      t.string :default_surrogate_kind
      t.integer :discipline_id
      t.integer :operation_id
      t.index :discipline_id
      t.index :operation_id
    end

    create_table :meta_model_prototypes do |t|
      t.integer :meta_model_id
      t.integer :prototype_id
      t.index :meta_model_id
      t.index :prototype_id
    end

    create_table :surrogates do |t|
      t.integer :coord_index
      t.string :kind
      t.integer :meta_model_id
      t.text :quality
      t.string :status
      t.integer :variable_id
      t.index :meta_model_id
      t.index :variable_id
    end
  end
end
