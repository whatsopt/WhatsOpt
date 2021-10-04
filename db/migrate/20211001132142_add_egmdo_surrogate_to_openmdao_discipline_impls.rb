class AddEgmdoSurrogateToOpenmdaoDisciplineImpls < ActiveRecord::Migration[6.1]
  def change
    add_column :openmdao_discipline_impls, :egmdo_surrogate, :boolean, null: false, default: false
  end
end
