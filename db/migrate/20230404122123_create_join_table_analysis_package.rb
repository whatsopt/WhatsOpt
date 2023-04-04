class CreateJoinTableAnalysisPackage < ActiveRecord::Migration[7.0]
  def change
    create_join_table :analyses, :packages, table_name: :packagings do |t|
      # t.index [:analysis_id, :package_id]
      # t.index [:package_id, :analysis_id]
    end
  end
end
