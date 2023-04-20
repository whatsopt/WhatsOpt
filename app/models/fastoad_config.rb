# frozen_string_literal: true

class FastoadConfig < ApplicationRecord
  include Ownable
  resourcify

  DEFAULT_MODULE_FOLDERS =  "./modules"
  DEFAULT_INPUT_FILE = "./input_file.xml"
  DEFAULT_OUTPUT_FILE = "./output_file.xml"

  belongs_to :analysis
  has_many :modules, class_name: "FastoadModule"

  validates :name, presence: true, uniqueness: true
  validates :module_folders, presence: true
  validates :input_file, presence: true
  validates :output_file, presence: true

  after_initialize :set_defaults

private

  def set_defaults
    self.module_folders = DEFAULT_MODULE_FOLDERS if module_folders.blank?
    self.input_file = DEFAULT_INPUT_FILE if input_file.blank?
    self.output_file  = DEFAULT_OUTPUT_FILE if output_file.blank?
  end

end
