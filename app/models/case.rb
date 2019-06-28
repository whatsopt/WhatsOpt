# frozen_string_literal: true

class Case < ApplicationRecord
  serialize :values

  belongs_to :operation
  belongs_to :variable

  validates :operation, presence: true
  validates :variable, presence: true

  scope :with_role_case, ->(role) { includes(:variable).references(:variables).joins("variables.outgoing_connections").where(connections: { role: role }).uniq }
  scope :inputs, ->(ope) { Case.where(operation: ope).with_role_case(WhatsOpt::Variable::INTEREST_INPUT_ROLES) }
  scope :outputs, ->(ope) { Case.where(operation: ope).with_role_case(WhatsOpt::Variable::INTEREST_OUTPUT_ROLES) }

  def nb_of_points
    values.size
  end

  def float_varname
    variable.name + (coord_index < 0 ? "" : "[#{coord_index}]")
  end
end
