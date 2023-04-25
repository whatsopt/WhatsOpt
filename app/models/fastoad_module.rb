# frozen_string_literal: true

class FastoadModule < ApplicationRecord
  belongs_to :fastoad_config
  belongs_to :custom_config, foreign_key: :custom_config_id, class_name: 'FastoadConfig'

  belongs_to :discipline

  validates :name, presence: true
  validates :discipline, presence: true
  validates :fastoad_id, presence: true, uniqueness: true

  def fullname
    discipline.fullname
  end

end
