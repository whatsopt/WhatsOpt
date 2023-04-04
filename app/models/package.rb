# frozen_string_literal: true

class Package < ApplicationRecord
  include Ownable

  has_one_attached :archive

  has_one :packaging, dependent: :destroy
  has_one :analyses, through: :packaging
  
end
