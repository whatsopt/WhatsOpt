class CreateScalings < ActiveRecord::Migration[5.2]
  def change
    create_table :scalings do |t|
      t.references :variable, foreign_key: true
      t.string :ref
      t.string :ref0
      t.string :res_ref
    end
  end
end
