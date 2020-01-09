class CreateDistributions < ActiveRecord::Migration[6.0]
  def change
    create_table :distributions do |t|
      t.string :kind, null: false
      t.references :variable, index: true
    end
  end
end
