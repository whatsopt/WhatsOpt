# frozen_string_literal: true

class Package < ApplicationRecord
  has_one_attached :archive

  has_one :packaging, dependent: :destroy
  has_one :analysis, through: :packaging

end
