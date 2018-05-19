class DropProjetsStudiesRuns < ActiveRecord::Migration[5.1]
  def up
    drop_table :runs
    drop_table :studies
    drop_table :projects
  end
  
  def down
  end
end
