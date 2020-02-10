# frozen_string_literal: true

class MetaModelPrototype < ApplicationRecord

  belongs_to :prototype, class_name: 'Analysis'
  belongs_to :meta_model

end
