class Attachment < ActiveRecord::Base

  has_attached_file :data,
                    :path => ":rails_root/upload/:attachment/:id/:style/:basename.:extension",
                    :processors => [:notebook_processor],
                    :styles => { html: {:format => :html} }

  before_post_process :before_post_process
  after_post_process :after_post_process

  def before_post_process
    puts "=== Before processing #{File.basename(data.path)} ==========="
  end
  
  def after_post_process
    puts "--- After processing #{File.basename(data.path)} ------------"
  end

  belongs_to :container, :polymorphic => true
  belongs_to :study, -> { where("attachments.container_type = 'Study'") }, foreign_key: 'container_id' 

  validates_attachment_presence  :data
  validates_attachment_size      :data, :less_than => 100.megabytes
  validates_attachment_file_name :data, :matches => [/\.ipynb\Z/]

end
