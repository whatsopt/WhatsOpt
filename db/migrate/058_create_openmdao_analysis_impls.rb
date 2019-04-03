class CreateOpenmdaoAnalysisImpls < ActiveRecord::Migration[5.2]
  def change
    create_table :openmdao_analysis_impls do |t|
      t.boolean    :parallel_group
      t.references :analysis, index: true
      t.references :nonlinear_solver, index: true
      t.references :linear_solver, index: true
    end
  end
end
