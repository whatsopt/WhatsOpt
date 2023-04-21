# frozen_string_literal: true

class FastoadModule < ApplicationRecord
  belongs_to :fastoad_config
  belongs_to :custom_config, foreign_key: :custom_config_id, class_name: 'FastoadConfig'

  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
end
