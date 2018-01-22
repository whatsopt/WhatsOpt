class InitializeTitleForNotebooks < ActiveRecord::Migration[5.1]
  def up
    Notebook.all.each do |nb|
      nb.title = "Notebook ##{nb.id}" if nb.title.blank?
      nb.save!
    end
  end
  
  def down
  end
end
