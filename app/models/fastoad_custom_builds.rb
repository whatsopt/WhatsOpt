# frozen_string_literal: true

class FastoadCustomBuilds < ApplicationRecord

  belongs_to :analysis
  belongs_to :fastoad_config

end
