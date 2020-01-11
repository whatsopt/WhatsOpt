# frozen_string_literal: true

class Option < ApplicationRecord
  belongs_to :optionizable, polymorphic: true
end
