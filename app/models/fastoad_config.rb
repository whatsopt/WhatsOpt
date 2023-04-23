# frozen_string_literal: true

class FastoadConfig < ApplicationRecord
  include Ownable
  resourcify

  DEFAULT_VERSION = "1.4.1"
  DEFAULT_MODULE_FOLDERS =  "./modules"
  DEFAULT_INPUT_FILE = "./input_file.xml"
  DEFAULT_OUTPUT_FILE = "./output_file.xml"

  belongs_to :analysis
  has_one :custom_analysis, class_name: 'Analysis'

  has_many :fastoad_modules
  has_many :custom_modules, foreign_key: "custom_config_id", class_name: 'FastoadModule'

  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
  validates :module_folders, presence: true
  validates :input_file, presence: true
  validates :output_file, presence: true

  after_initialize :set_defaults

  def load_conf(version)
    filepath = File.join(Rails.root, "config", "fastoad", "fastoad_config_1.4.1.yml")
    conf = YAML.load(File.open(filepath).read)
    conf
  end

  def list_modules(model)
    modules = []
    model.each do |k, mod|
      next if ["linear_solver", "nonlinear_solver"].include?(k)
      if mod['id']
        modules << FastoadModule.new(name: k, version: "1.4.1", fastoad_id: mod['id'])
      else
        modules += list_modules(mod)
      end
    end
    modules
  end

private

  def set_defaults
    self.version = DEFAULT_VERSION if version.blank?

    if fastoad_modules.blank?
      conf = self.load_conf(self.version)
      self.module_folders = conf['module_folders']
      self.input_file = conf['input_file']
      self.output_file = conf['output_file']

      modules = list_modules(conf['model'])
      self.fastoad_modules = modules
    end
    self.module_folders = DEFAULT_MODULE_FOLDERS if module_folders.blank?
    self.input_file = DEFAULT_INPUT_FILE if input_file.blank?
    self.output_file  = DEFAULT_OUTPUT_FILE if output_file.blank?
    self.analysis = Analysis.find_by_name("FAST_OAD_v141") if analysis.blank?
  end

end
