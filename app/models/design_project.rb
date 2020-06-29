# frozen_string_literal: true

class DesignProject < ApplicationRecord

  include Ownable
  resourcify

  has_many :design_project_filings, dependent: :destroy
  has_many :analyses, through: :design_project_filings
  
end