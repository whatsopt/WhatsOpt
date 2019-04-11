class CreateScalings < ActiveRecord::Migration[5.2]
  def change
    create_table :scalings do |t|
      t.references :variable, foreign_key: true
      t.string :ref, default: ""
      t.string :ref0, default: ""
      t.string :res_ref, default: ""
    end
  end
end
