require 'whats_opt/surrogate_server/surrogate_store_types'

class Surrogate < ApplicationRecord
  belongs_to :meta_model
  belongs_to :variable

  validates :meta_model, presence: true
  validates :variable, presence: true
  validates :coord_index, presence: true

  SURROGATES = %w(KRIGING KPLS KPLSK LS QP)
  STATUS_CREATED = "created"
  STATUS_TRAINED = "trained"
  STATUS_FAILED = "failed"
  STATUSES = [STATUS_CREATED, STATUS_TRAINED, STATUS_FAILED]

  SURROGATE_MAP = {
    KRIGING: WhatsOpt::SurrogateServer::SurrogateKind::KRIGING,
    KPLS: WhatsOpt::SurrogateServer::SurrogateKind::KPLS,
    KPLSK: WhatsOpt::SurrogateServer::SurrogateKind::KPLSK,
    LS: WhatsOpt::SurrogateServer::SurrogateKind::LS,
    QP: WhatsOpt::SurrogateServer::SurrogateKind::QP
  }

  after_initialize :_set_defaults

  def surr_proxy
    @surr_proxy ||= WhatsOpt::SurrogateProxy.new(id)
  end

  def float_varname
    variable.name + (coord_index < 0 ? "" : "[#{coord_index}]")
  end

  def trained?
    status == STATUS_TRAINED
  end

  def train
    xt = meta_model.training_input_values
    yt = meta_model.training_output_values(variable.name, coord_index)
    surr_kind = SURROGATE_MAP[kind.to_sym]
    surr_proxy.create_surrogate(surr_kind, xt, yt)
  end
  
  def predict(x)

  end

  private

  def _set_defaults
    self.kind = SURROGATES[0] if self.kind.blank? 
    self.status = STATUS_CREATED if self.status.blank? 
  end
end
