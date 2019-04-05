class CreateOpenmdaoDisciplineImpls < ActiveRecord::Migration[5.2]
  def change
    create_table :openmdao_discipline_impls do |t|
      t.boolean    :implicit_component
      t.boolean    :support_derivatives
      t.references :discipline, index: true
    end
  end
end
