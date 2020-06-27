class CreateJoinTableDesignProjectAnalysis < ActiveRecord::Migration[6.0]
  def change
    create_join_table :design_projects, :analyses, name: :design_project_filing do |t|
      t.index [:design_project_id, :analysis_id], name: :index_design_project_id_analysis_id
      t.index [:analysis_id, :design_project_id], name: :index_analysis_id_design_project_id
    end
  end
end
