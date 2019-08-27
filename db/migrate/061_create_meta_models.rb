class CreateMetaModels < ActiveRecord::Migration[5.2]
  def change
    create_table :meta_models do |t|
      t.references :discipline
      t.references :operation

      t.string :default_surrogate_kind

      t.timestamps
    end
  end
end
