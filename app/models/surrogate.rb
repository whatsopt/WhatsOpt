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
  STATUS_DELETED = "failed"
  STATUSES = [STATUS_CREATED, STATUS_TRAINED, STATUS_FAILED, STATUS_DELETED]

  SURROGATE_MAP = {
    KRIGING: WhatsOpt::SurrogateServer::SurrogateKind::KRIGING,
    KPLS: WhatsOpt::SurrogateServer::SurrogateKind::KPLS,
    KPLSK: WhatsOpt::SurrogateServer::SurrogateKind::KPLSK,
    LS: WhatsOpt::SurrogateServer::SurrogateKind::LS,
    QP: WhatsOpt::SurrogateServer::SurrogateKind::QP
  }

  after_initialize :_set_defaults
  before_destroy :_delete_surrogate

  def proxy
    WhatsOpt::SurrogateProxy.new(surrogate_id: id.to_s)
  end

  def float_varname
    variable.name + (coord_index < 0 ? "" : "[#{coord_index}]")
  end

  def trained?
    self.status == STATUS_TRAINED
  end

  def qualified?
    false
  end

  def train(test_part: 10)
    all_xt = meta_model.training_input_values
    indices = []
    if test_part > 1 and test_part < all_xt.size/2
      indices = (0...all_xt.size).step(test_part)
    end 
    xt, xv = _extract_at_indices(all_xt, indices)
    all_yt = meta_model.training_output_values(variable.name, coord_index)
    yt, yv = _extract_at_indices(all_yt, indices)
    surr_kind = SURROGATE_MAP[kind.to_sym]
    proxy.create_surrogate(surr_kind, xt, yt)
    unless indices.to_a.empty? 
      quality = proxy.qualify(xv, yv)
    end 
    update(status: STATUS_TRAINED)
  rescue WhatsOpt::SurrogateServer::SurrogateException => exc
    Rails.logger.warn "SURROGATE TRAIN: #{exception} on surrogate #{id}: #{exc}"
    update(status: STATUS_FAILED)
  ensure
    save!
  end
  
  def predict(x)
    train unless trained?
    y = proxy.predict_values(x)
  rescue => exception
    # puts "#{exception} on surrogate #{id}"
    Rails.logger.warn "SURROGATE PREDICT: #{exception} on surrogate #{id}: #{exception.msg}"
    update(status: STATUS_FAILED)
    raise
  else
    y
  end

  def _extract_at_indices(vals, indices)
    xt = vals.select.with_index {|v, i| !indices.include?(i)}
    xv = indices.map {|i| vals[i]} 
    return xt, xv 
  end

  private

  def _set_defaults
    self.kind = SURROGATES[0] if self.kind.blank? 
    self.status = STATUS_CREATED if self.status.blank? 
  end

  def _delete_surrogate
    update(status: STATUS_DELETED)
    proxy.destroy_surrogate
  end

end
