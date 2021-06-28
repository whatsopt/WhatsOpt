class AddUseUnitsToOpenmdaoAnalysisImpls < ActiveRecord::Migration[6.1]
  def change
    add_column :openmdao_analysis_impls, :use_units, :boolean
  end
end
