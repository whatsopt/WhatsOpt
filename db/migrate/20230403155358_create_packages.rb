class CreatePackages < ActiveRecord::Migration[7.0]
  def change
    create_table :packages do |t|
      t.text :description
      t.references :analysis, foreign_key: true, type: :integer
      
      t.timestamps
    end
  end
end
