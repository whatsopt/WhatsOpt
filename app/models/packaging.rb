# frozen_string_literal: true

class Packaging < ApplicationRecord
  belongs_to :package, touch: true
  belongs_to :analysis
end
