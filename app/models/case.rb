# frozen_string_literal: true

class Case < ApplicationRecord
  serialize :values

  belongs_to :operation
  belongs_to :variable

  scope :with_role_case, ->(role) { includes(:variable).references(:variables).joins(variable: :outgoing_connections).where(connections: { role: role }).uniq }
  scope :inputs, ->(ope) { where(operation: ope).with_role_case(WhatsOpt::Variable::INTEREST_INPUT_ROLES) }
  scope :outputs, ->(ope) { where(operation: ope).with_role_case(WhatsOpt::Variable::INTEREST_OUTPUT_ROLES) }
  scope :uncertains, -> { joins(variable: :distributions) }

  def nb_of_points
    values.size
  end

  def var_label
    @label ||= Case.label(variable.name, coord_index)
  end

  def self.label(name, coord)
    name + (coord < 0 ? "" : "[#{coord}]")
  end

  def build_copy(operation, variable = nil)
    copy = self.dup
    copy.variable = variable unless variable.nil?
    copy.operation = operation
    copy
  end
end
