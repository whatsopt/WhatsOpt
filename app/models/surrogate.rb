class Surrogate < ApplicationRecord
  belongs_to :meta_model
  belongs_to :variable

  validates :meta_model, presence: true
  validates :variable, presence: true
  validates :coord_index, presence: true

  SURROGATES = %w(KRIGING KPLS KPLSK LS QP)
  STATUSES = %w(CREATED, TRAINED, FAILED)

  after_initialize :_set_defaults

  def float_varname
    variable.name + (coord_index < 0 ? "" : "[#{coord_index}]")
  end

  private

  def _set_defaults
    self.kind = SURROGATES[0] if self.kind.blank? 
    self.status = STATUSES[0] if self.status.blank? 
  end
end
