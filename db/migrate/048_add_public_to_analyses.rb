class AddPublicToAnalyses < ActiveRecord::Migration[5.2]
  def change
    add_column :analyses, :public, :boolean, default: false
  end
end
