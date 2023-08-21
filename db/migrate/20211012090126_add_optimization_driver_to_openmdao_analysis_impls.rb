# frozen_string_literal: true

class AddOptimizationDriverToOpenmdaoAnalysisImpls < ActiveRecord::Migration[6.1]
  def change
    add_column :openmdao_analysis_impls, :optimization_driver, :string
  end
end
