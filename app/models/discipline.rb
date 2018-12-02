require 'whats_opt/openmdao_module'
require 'whats_opt/discipline'

class Discipline < ApplicationRecord
  
  include WhatsOpt::Discipline
  include WhatsOpt::OpenmdaoModule
  
  self.inheritance_column = :disable_inheritance
    
  #has_many :variables, -> { includes(:parameter) }, :dependent => :destroy
  has_many :variables, :dependent => :destroy
  has_one :analysis_discipline, :dependent => :destroy
  has_one :sub_analysis, through: :analysis_discipline, source: :analysis
  
  belongs_to :analysis
  acts_as_list scope: :analysis, top_of_list: 0
  
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true, allow_blank: false
  
  scope :driver, -> { where( type: WhatsOpt::Discipline::NULL_DRIVER ) }
  scope :nodes, -> { where.not( type: WhatsOpt::Discipline::NULL_DRIVER ) }
  scope :by_position, -> { order(position: :asc) }

  after_initialize :set_defaults, unless: :persisted?  
    
  def input_variables
    variables.inputs
  end

  def output_variables
    variables.outputs
  end

  def is_driver?
    type == WhatsOpt::Discipline::NULL_DRIVER
  end
  
  def update_discipline(params)
    Discipline.transaction do 
      if params[:position]
        insert_at(params[:position])
        params = params.except(:role) 
      end
      update(params)
      if (sub_analysis && type != WhatsOpt::Discipline::ANALYSIS)
        analysis_discipline.analysis.update(parent_id: nil)
        analysis_discipline.destroy 
      end
    end
  end
  
  private 

  def set_defaults
    type = WhatsOpt::Discipline::DISCIPLINE if self.type.blank?
    if name == WhatsOpt::Discipline::NULL_DRIVER_NAME
      type = WhatsOpt::Discipline::NULL_DRIVER
    end
  end
  
end
