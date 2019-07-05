class MetaModel < ApplicationRecord
  belongs_to :analysis
  belongs_to :operation

  has_many :surrogates, dependent: :destroy

  validates :analysis, presence: true

  after_initialize :_set_defaults

  def build_surrogates
    analysis.response_variables.each do |v|
      (0...v.dim).each do |index|
        surrogates.build(variable: v, coord_index: index-1)
      end
    end
  end

private

  def _set_defaults
    self.default_surrogate_kind = Surrogate::SURROGATES[0] if self.default_surrogate_kind.blank? 
  end
  
end
