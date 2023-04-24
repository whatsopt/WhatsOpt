# frozen_string_literal: true

class FastoadConfig < ApplicationRecord
  include Ownable
  resourcify

  DEFAULT_VERSION = "1.4.1"
  DEFAULT_MODULE_FOLDERS =  "./modules"
  DEFAULT_INPUT_FILE = "./input_file.xml"
  DEFAULT_OUTPUT_FILE = "./output_file.xml"

  belongs_to :analysis
  has_one :custom_analysis, foreign_key: "custom_config_id", class_name: "Analysis", dependent: :destroy

  has_many :fastoad_modules, dependent: :destroy
  has_many :custom_modules, foreign_key: "custom_config_id", class_name: "FastoadModule", dependent: :destroy

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

  def list_modules(fastoad_conf_model)
    modules = []
    fastoad_conf_model.each do |k, mod|
      next if ["linear_solver", "nonlinear_solver"].include?(k)
      if mod['id']
        modules << FastoadModule.new(name: k, version: "1.4.1", fastoad_id: mod['id'])
      else
        modules += list_modules(mod)
      end
    end
    modules
  end

  def update_custom_modules
    disciplines = self._compute_disciplines_diff
    self._update_custom_modules_from_diff(disciplines)
  end

  def _compute_disciplines_diff
    ref_discs = self.analysis.all_plain_disciplines
    custom_discs = self.custom_analysis.all_plain_disciplines 
    discs_diff = []
    custom_discs.each do |custom_disc|
      found = false
      ref_discs.each do |ref_disc|
        if custom_disc.fullname == ref_disc.fullname and custom_disc.position == ref_disc.position
          found = true
          break
        end
      end
      next if found
      discs_diff << custom_disc
    end
    discs_diff
  end

  def _update_custom_modules_from_diff(disciplines)
    cmp = disciplines.zip(self.custom_modules)
    cmp.each do |disc, cm|
      if cm
        if disc
          cm.update(name: disc.name, fastoad_id: disc.fullname)
        end 
      else
        self.custom_modules.create(name: disc.name, fastoad_id: disc.fullname)
      end
    end
    while self.custom_modules.count > disciplines.size do
      self.custom_modules.last.destroy
    end
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
