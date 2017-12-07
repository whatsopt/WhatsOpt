class CreateGeometryModels < ActiveRecord::Migration[5.1]
  def change
    create_table :geometry_models do |t|
      t.string :title

      t.timestamps
    end
  end
end
