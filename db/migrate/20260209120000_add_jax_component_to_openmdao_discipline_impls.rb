# frozen_string_literal: true

class AddJaxComponentToOpenmdaoDisciplineImpls < ActiveRecord::Migration[6.1]
  def change
    add_column :openmdao_discipline_impls, :jax_component, :boolean, null: false, default: false
  end
end
