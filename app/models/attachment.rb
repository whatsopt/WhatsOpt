class Attachment < ActiveRecord::Base

  has_attached_file :data,
                    :path => ":rails_root/upload/:attachment/:id/:style/:basename.:extension",
                    :processors => -> (a) { if a.notebook?
                                              [:notebook_processor]
                                            else
                                              []
                                            end },  
                    :styles => -> (a) { if a.instance.notebook?
                                          { html: {:format => :html} }
                                        else 
                                          {}
                                        end }
                                                          
                    { html: {:format => :html} }

  ATTACH_RAW = "Raw"
  ATTACH_NOTEBOOK = "Notebook"
  ATTACH_MDA_TEMPLATE = "MdaTemplate"
  ATTACHMENT_CATEGORIES = [ATTACH_RAW, ATTACH_NOTEBOOK, ATTACH_MDA_TEMPLATE]  

  belongs_to :container, :polymorphic => true
  belongs_to :study, -> { where("attachments.container_type = 'Study'") }, foreign_key: 'container_id' 
  belongs_to :notebook, -> { where("attachments.container_type = 'Notebook'") }, foreign_key: 'container_id' 
  belongs_to :mda_template, -> { where("attachments.container_type = 'MultiDisciplinaryAnalysis'") }, foreign_key: 'container_id' 

  after_initialize :ensure_category_setting, on: :create
  before_post_process :ensure_category_setting
    
  validates_attachment_presence  :data
  validates_attachment_size      :data, :less_than => 100.megabytes
  validates_attachment_file_name :data, :matches => [/\.ipynb\Z/, /\.xlsm\Z/]

  scope :notebooks, -> { where(category: ATTACH_NOTEBOOK) }
  scope :mda_template, -> { where(category: ATTACH_MDA_TEMPLATE) }

  def exists?
    data.exists?
  end
  
  def notebook?
    self.category == ATTACH_NOTEBOOK
  end
  
  def path
    data.path
  end
      
  private

  def ensure_category_setting
    unless self.category
      case self.data_file_name
      when /\.ipynb\Z/
        self.category = ATTACH_NOTEBOOK
      when /\.xlsm\Z/ 
        self.category = ATTACH_MDA_TEMPLATE
      else
        self.category = ATTACH_RAW
      end
    end
  end

end
