# frozen_string_literal: true

class Packaginging < ApplicationRecord
  belongs_to :package, touch: true
  belongs_to :analysis
end
