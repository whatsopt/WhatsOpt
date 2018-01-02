class InitializePositionOfExistingDisciplines < ActiveRecord::Migration[5.1]
  def change
    MultiDisciplinaryAnalysis.all.each do |mda|
      mda.disciplines.order(:updated_at).each.with_index(1) do |discipline, index|
        discipline.update_column :position, index
      end
    end
  end
end
