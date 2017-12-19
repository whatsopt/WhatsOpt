class AttachmentNotFound < StandardError
end

class Attachment < ActiveRecord::Base

  has_attached_file :data,
                    :path => ":rails_root/upload/:attachment/:id/:style/:basename.:extension",
                    :processors => -> (a) { if a.notebook?
                                              [:notebook_processor]
                                            elsif a.geometry_model?
                                              [:geometry_model_processor]
                                            else
                                              []
                                            end },  
                    :styles => -> (a) { if a.instance.notebook?
                                          { html: {:format => :html} }
                                        elsif a.instance.geometry_model?
                                          { x3d: {:format => :x3d} }
                                        else 
                                          {}
                                        end }
                                                          
                    { html: {:format => :html} }

  NOT_FOUND = '__NOT_FOUND__'
  ATTACH_UNDEFINED = "Undefined"
  ATTACH_NOTEBOOK = "Notebook"
  ATTACH_MDA_EXCEL = "MdaExcel"
  ATTACH_MDA_CMDOWS = "MdaCmdows"
  ATTACH_GEOMETRY_MODEL = "GeometryModel"
  ATTACHMENT_CATEGORIES = [ATTACH_UNDEFINED, ATTACH_NOTEBOOK, ATTACH_MDA_EXCEL, ATTACH_MDA_CMDOWS, ATTACH_GEOMETRY_MODEL]  

  belongs_to :container, :polymorphic => true
  belongs_to :study, -> { where("attachments.container_type = 'Study'") }, foreign_key: 'container_id' 
  belongs_to :notebook, -> { where("attachments.container_type = 'Notebook'") }, foreign_key: 'container_id' 
  belongs_to :mda_excel, -> { where("attachments.container_type = 'MultiDisciplinaryAnalysis'") }, foreign_key: 'container_id' 
  belongs_to :mda_cmdows, -> { where("attachments.container_type = 'MultiDisciplinaryAnalysis'") }, foreign_key: 'container_id' 
  belongs_to :geometry_model, -> { where("attachments.container_type = 'GeometryModel'") }, foreign_key: 'container_id' 

  after_initialize :ensure_category_setting, on: :create
  before_post_process :ensure_category_setting
    
  validates_attachment_presence  :data
  validates_attachment_size      :data, :less_than => 100.megabytes
  validates_attachment_file_name :data, :matches => [/\.ipynb\Z/, /\.xlsx\Z/, /\.cmdows\Z/, /\.vsp3\Z/]

  scope :notebooks, -> { where(category: ATTACH_NOTEBOOK) }
  scope :mda_excel, -> { where(category: ATTACH_MDA_EXCEL) }
  scope :mda_cmdows, -> { where(category: ATTACH_MDA_CMDOWS) }

  def exists?
    Pathname.new(self.path).exist?
  end
  
  def notebook?
    self.category == ATTACH_NOTEBOOK
  end

  def geometry_model?
    self.category == ATTACH_GEOMETRY_MODEL
  end
    
  def mda_excel?
    self.category == ATTACH_MDA_EXCEL
  end

  def mda_cmdows?
    self.category == ATTACH_MDA_CMDOWS
  end
  
  def original_filename
    if data
      data.original_filename
    else
      raise AttachmentNotFound.new
    end
  end
  
  def path
    if data.exists?
      data.path
    elsif Pathname.new(data.queued_for_write[:original].path).exist?
      data.queued_for_write[:original].path
    else
      raise AttachmentNotFound.new
    end
  end
        
  private

  def ensure_category_setting
    unless self.category
      case self.data_file_name
      when /\.ipynb\Z/
        self.category = ATTACH_NOTEBOOK
      when /\.xlsx\Z/ 
          self.category = ATTACH_MDA_EXCEL
      when /\.cmdows\Z/ 
          self.category = ATTACH_MDA_CMDOWS
      when /\.vsp3\Z/ 
          self.category = ATTACH_GEOMETRY_MODEL
      else
        self.category = ATTACH_UNDEFINED
      end
    end
  end

end
