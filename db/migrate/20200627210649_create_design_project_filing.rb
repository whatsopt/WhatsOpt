# frozen_string_literal: true

class CreateDesignProjectFiling < ActiveRecord::Migration[6.0]
  def change
    create_table :design_project_filings do |t|
      t.integer "design_project_id"
      t.integer "analysis_id"
      t.index ["analysis_id"], name: "index_design_project_filings_on_analysis_id"
      t.index ["design_project_id"], name: "index_design_project_filings_on_design_project_id"
    end
  end
end
