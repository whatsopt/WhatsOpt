class InitializeLowerUpperParameterValues < ActiveRecord::Migration[5.1]
  def change
    Parameter.all.each do |p|
      p.update_column(:lower, "") if p.lower.blank?
      p.update_column(:upper, "") if p.upper.blank?
    end
  end
end
