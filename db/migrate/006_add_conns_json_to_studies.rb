class AddConnsJsonToStudies < ActiveRecord::Migration[5.0]
  def change
    add_column :studies, :conns_json, :text
  end
end
