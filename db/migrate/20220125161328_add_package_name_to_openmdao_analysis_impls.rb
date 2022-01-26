class AddPackageNameToOpenmdaoAnalysisImpls < ActiveRecord::Migration[6.1]
  def change
    add_column :openmdao_analysis_impls, :package_name, :string
  end
end
