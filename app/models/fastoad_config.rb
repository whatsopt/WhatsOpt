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

  def create_custom_analysis(user)
    mda = self.analysis.create_copy!
    mda.name = mda.name + "_Custom"
    journal = mda.init_journal(user)
    journal.journalize(mda, Journal::COPY_ACTION)
    mda.set_owner(user)
    mda.save_journal
    self.custom_analysis = mda
  end

  def update_custom_modules
    disciplines = self._compute_disciplines_diff
    self._update_custom_modules_from_diff(disciplines)
  end

  def _compute_disciplines_diff
    ref_discs = self.analysis.all_plain_disciplines_depth_first
    custom_discs = self.custom_analysis.all_plain_disciplines_depth_first 
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

  def _update_custom_modules_from_diff(custom_disciplines)
    cmp = custom_disciplines.zip(self.custom_modules)
    cmp.each do |disc, cm|
      if cm
        if disc
          cm.update(name: disc.name, fastoad_id: disc.fullname, discipline: disc)
        end 
      else
        self.custom_modules.create(name: disc.name, fastoad_id: disc.fullname, discipline: disc)
      end
    end

    # FIXME: As discipline deletion remove also related module (dependent: destroy)
    # The following is not needed anymore
    # (custom_disciplines.size..self.custom_modules.count).each do |_|
    #   self.custom_modules.last.destroy
    # end
  end

  private


  def list_modules_from_conf(fastoad_conf_model, root="")
    modules = []
    fastoad_conf_model.each do |k, mod|
      next if ["linear_solver", "nonlinear_solver"].include?(k)
      if mod['id']
        modules << {name: k, fullname: (root == "" ? k : root + ".#{k}"), fastoad_id: mod['id']}
      else
        modules += list_modules_from_conf(mod, (root == "" ? k : root + ".#{k}"))
      end
    end
    modules
  end

  def set_defaults
    self.version = DEFAULT_VERSION if version.blank?

    conf = self.load_conf(self.version)
    self.module_folders = conf['module_folders']
    self.input_file = conf['input_file']
    self.output_file = conf['output_file']

    self.module_folders = DEFAULT_MODULE_FOLDERS if module_folders.blank?
    self.input_file = DEFAULT_INPUT_FILE if input_file.blank?
    self.output_file  = DEFAULT_OUTPUT_FILE if output_file.blank?
    self.analysis = Analysis.find_by_name("FAST_OAD_v141") if analysis.blank?

    if fastoad_modules.blank?
      modules = list_modules_from_conf(conf['model'])
      
      fastoad_disciplines = self.analysis.all_disciplines
      module_infos = list_modules_from_conf(conf['model'])
      p module_infos
      p fastoad_disciplines.map {|d| d.is_sub_analysis? ? d.sub_packagename : d.fullname}

      module_infos.each_with_index do |info|
        found = false
        fastoad_disciplines.each do |disc|
          fullname = if disc.is_sub_analysis? 
            disc.sub_packagename
          else
            disc.fullname
          end
          
          if fullname == info[:fullname]
            found = true
            p "BUILD name: #{disc.name}, fastoad_id: #{info[:fastoad_id]}, discipline: #{disc.id}"
            self.fastoad_modules.build(name: disc.name, fastoad_id: info[:fastoad_id], discipline: disc)
            break
          end
        end
        unless found
          Rails.logger.error "FastOAD conf read from conf file #{self.version} inconsistent with Analysis ##{self.analysis.id}"
          Rails.logger.error "  #{info[:fullname]} module not found in ##{self.analysis.id})"
          self.errors.add(:base, message: "FastOAD conf #{self.version} vs Analysis #{self.analysis.name} ##{self.analysis.id} : #{info[:fullname]} module not found in ##{self.analysis.id})")
        end
      end
    end
  end

end
