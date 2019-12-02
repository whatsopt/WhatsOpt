# frozen_string_literal: true

require "whats_opt/surrogate_server/surrogate_store_types"

class Surrogate < ApplicationRecord
  SURROGATE_MAP = {
    KRIGING: WhatsOpt::SurrogateServer::SurrogateKind::KRIGING,
    KPLS: WhatsOpt::SurrogateServer::SurrogateKind::KPLS,
    KPLSK: WhatsOpt::SurrogateServer::SurrogateKind::KPLSK,
    LS: WhatsOpt::SurrogateServer::SurrogateKind::LS,
    QP: WhatsOpt::SurrogateServer::SurrogateKind::QP
  }

  store :quality, accessors: [:r2, :xvalid, :yvalid, :ypred], coder: JSON

  belongs_to :meta_model
  belongs_to :variable

  validates :meta_model, presence: true
  validates :variable, presence: true
  validates :coord_index, presence: true

  SURROGATES = %w(KRIGING KPLS KPLSK LS QP)
  validates :kind, inclusion: { in: SURROGATES }

  STATUS_CREATED = "created"
  STATUS_TRAINED = "trained"
  STATUS_FAILED = "failed"
  STATUS_DELETED = "failed"
  STATUSES = [STATUS_CREATED, STATUS_TRAINED, STATUS_FAILED, STATUS_DELETED]

  after_initialize :_set_defaults
  #after_save :_activate_copy, if: :copy_in_progress?
  before_destroy :_delete_surrogate

  # transient attribute to manage surrogate copy
  #attr_accessor :copy_origin_id

  def proxy
    WhatsOpt::SurrogateProxy.new(surrogate_id: id.to_s)
  end

  def float_varname
    variable.name + (coord_index < 0 ? "" : "[#{coord_index}]")
  end

  def trained?
    self.status == STATUS_TRAINED
  end

  # def copy_in_progress?
  #   !!self.copy_origin_id
  # end

  def qualified?
    !self.xvalid.empty?
  end

  def train(test_part: 10)
    if meta_model.operation
      all_xt = meta_model.training_input_values
      indices = (0...all_xt.size).step(test_part)
      xt, self.xvalid = _extract_at_indices(all_xt, indices)
      all_yt = meta_model.training_output_values(variable.name, coord_index)
      yt, self.yvalid = _extract_at_indices(all_yt, indices)
      surr_kind = SURROGATE_MAP[kind.to_sym]
      proxy.create_surrogate(surr_kind, xt, yt)
      unless indices.to_a.empty?
        quality = proxy.qualify(self.xvalid, self.yvalid)
        self.r2, self.ypred = quality.r2, quality.yp
      end
      self.status = STATUS_TRAINED
    else
      Rails.logger.warn "MetaModel DOE operation removed: Cannot train surrogates of MetaModel ##{meta_model.id}"
      self.status = STATUS_FAILED
    end
  rescue WhatsOpt::SurrogateServer::SurrogateException => exc
    Rails.logger.warn "SURROGATE TRAIN: #{exception} on surrogate #{id}: #{exc}"
    self.status = STATUS_FAILED
  ensure
    save!
  end

  def qualify(test_part: 10, force: false)
    train(test_part: test_part) if force || !qualified?
    { name: variable.name, kind: kind, r2: self.r2, xvalid: self.xvalid, yvalid: self.yvalid, ypred: self.ypred }
  end

  def predict(x)
    train unless trained?
    y = proxy.predict_values(x)
  rescue WhatsOpt::SurrogateServer::SurrogateException => exc
    Rails.logger.warn "SURROGATE TRAIN: #{exception} on surrogate #{id}: #{exc.msg}"
    self.status = STATUS_FAILED
  rescue => exception
    # puts "#{exception} on surrogate #{id}"
    Rails.logger.warn "SURROGATE PREDICT: #{exception} on surrogate #{id}: #{exception}"
    update(status: STATUS_FAILED)
    raise
  else
    y
  end

  def _extract_at_indices(vals, indices)
    xt = vals.select.with_index { |v, i| !indices.include?(i) }
    xv = indices.map { |i| vals[i] }
    return xt, xv
  end

  def build_copy(mm=nil, var=nil)
    copy = self.dup
    copy.quality = nil
    copy.status = STATUS_CREATED
    copy.variable = var || self.variable
    #copy.copy_origin_id = self.id if self.trained? 
    mm.surrogates << copy if mm
    copy
  end

  private
    def _set_defaults
      self.kind = SURROGATES[0] if self.kind.blank?
      self.status = STATUS_CREATED if self.status.blank?
      self.r2 = -1.0 if self.r2.blank?
      self.xvalid = [] if self.xvalid.blank?
      self.yvalid = [] if self.yvalid.blank?
      self.ypred = [] if self.ypred.blank?
    end

    def _delete_surrogate
      update(status: STATUS_DELETED)
      proxy.destroy_surrogate
    end

    # def _activate_copy
    #   # trigger actual copy of surrogate on the disk
    #   if self.copy_origin_id && self.id != self.copy_origin_id
    #     p "ACTIVATE"
    #     proxy.copy_surrogate(self.copy_origin_id.to_s)
    #     self.copy_origin_id = nil
    #   end
    # end
end
