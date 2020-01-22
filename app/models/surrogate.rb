# frozen_string_literal: true

require "whats_opt/surrogate_server/surrogate_store_types"

class Surrogate < ApplicationRecord
  SMT_KRIGING = "SMT_KRIGING"
  SMT_KPLS = "SMT_KPLS"
  SMT_KPLSK = "SMT_KPLSK"
  SMT_LS = "SMT_LS"
  SMT_QP = "SMT_QP"
  OPENTURNS_PCE = "OPENTURNS_PCE"

  SURROGATES = [SMT_KRIGING, SMT_KPLS, SMT_KPLSK, 
                SMT_LS, SMT_QP, OPENTURNS_PCE]
  
  SURROGATE_MAP = {
    "SMT_KRIGING" => WhatsOpt::SurrogateServer::SurrogateKind::SMT_KRIGING,
    "SMT_KPLS" => WhatsOpt::SurrogateServer::SurrogateKind::SMT_KPLS,
    "SMT_KPLSK" => WhatsOpt::SurrogateServer::SurrogateKind::SMT_KPLSK,
    "SMT_LS" => WhatsOpt::SurrogateServer::SurrogateKind::SMT_LS,
    "SMT_QP" => WhatsOpt::SurrogateServer::SurrogateKind::SMT_QP,
    "OPENTURNS_PCE" => WhatsOpt::SurrogateServer::SurrogateKind::OPENTURNS_PCE
  }

  STATUS_CREATED = "created"
  STATUS_TRAINED = "trained"
  STATUS_FAILED = "failed"
  STATUS_DELETED = "deleted"
  STATUSES = [STATUS_CREATED, STATUS_TRAINED, STATUS_FAILED, STATUS_DELETED]

  store :quality, accessors: [:r2, :xvalid, :yvalid, :ypred], coder: JSON

  belongs_to :meta_model
  belongs_to :variable
  
  has_many :options, as: :optionizable, dependent: :destroy
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true 

  validates :meta_model, presence: true
  validates :variable, presence: true
  validates :coord_index, presence: true

  validates :kind, inclusion: { in: SURROGATES }

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
    !self.xvalid.empty?
  end

  def train(test_part: 10)
    if meta_model.operation
      all_xt = meta_model.training_input_values
      indices = (0...all_xt.size).step(test_part)
      xt, self.xvalid = _extract_at_indices(all_xt, indices)
      all_yt = meta_model.training_output_values(variable.name, coord_index)
      yt, self.yvalid = _extract_at_indices(all_yt, indices)
      surr_kind = SURROGATE_MAP[kind]
      unless surr_kind
        Rails.logger.warn "Surrogate kind '#{kind}' unkonwn: use SMT Kriging as default"
        surr_kind = SURROGATE_MAP[SMT_KRIGING]
      end
      opts = options.inject({}){|acc, o| acc.update({o.name => o.value})}
      uncs = meta_model.training_input_uncertainties
      proxy.create_surrogate(surr_kind, xt, yt, opts, uncs)
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
    Rails.logger.warn "SURROGATE TRAIN: Errror on surrogate #{id}: #{exc.msg}"
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
    Rails.logger.warn "SURROGATE TRAIN: #{exc} on surrogate #{id}: #{exc.msg}"
    self.status = STATUS_FAILED
  rescue => exception
    # puts "#{exception} on surrogate #{id}"
    Rails.logger.warn "SURROGATE PREDICT: #{exception} on surrogate #{id}: #{exception}"
    update(status: STATUS_FAILED)
    raise
  else
    y
  end

  def get_sobol_pce_sensitivity_analysis
    train unless trained?
    if kind == OPENTURNS_PCE && trained?
      infos = proxy.get_sobol_pce_sensitivity_analysis
      {
        "#{variable.name}" => {
          "S1" => infos.S1, 
          "ST" => infos.ST, 
          "parameter_names" => self.meta_model.training_input_names
        } 
      }
    else
      Rails.logger.warn "Can not get sensitivity analysis as surrogate"\
                         " for #{self.variable.name} has #{self.status} status" unless trained?
      Rails.logger.warn "Can not get sensitivity analysis as surrogate"\
                         " for #{self.variable.name} is of kind #{kind}" unless kind == OPENTURNS_PCE
      {}
    end
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
    self.options.each do |opt|
      copy.options << opt.build_copy
    end
    mm.surrogates << copy if mm
    copy
  end

  private
    def _set_defaults
      self.kind = SMT_KRIGING if self.kind.blank?
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

end
