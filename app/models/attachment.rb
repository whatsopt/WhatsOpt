class Attachment < ActiveRecord::Base

  has_attached_file :data,
                    :path => ":rails_root/upload/:attachment/:id/:style/:basename.:extension",
                    :processors => [:notebook_processor],
                    :styles => { html: {:format => :html} }

  ATTACHMENT_CATEGORIES = %w(Notebook, Openmdao)

  belongs_to :container, :polymorphic => true
  belongs_to :study, -> { where("attachments.container_type = 'Study'") }, foreign_key: 'container_id' 

  validates :category, presence: true
  validates_attachment_presence  :data
  validates_attachment_size      :data, :less_than => 100.megabytes
  validates_attachment_file_name :data, :matches => [/\.ipynb\Z/, /.json\Z/]

  after_initialize :_post_initialize

  scope :notebooks, -> { where(category: 'Notebook') }
  
  private
  
  def _post_initialize
    _initialize_category if category.blank?
  end

  def _initialize_category
    self.category = "Notebook"
  end

end
