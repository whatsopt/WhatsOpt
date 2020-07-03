# frozen_string_literal: true

class DesignProjectFiling < ApplicationRecord
  belongs_to :design_project
  belongs_to :analysis
end
