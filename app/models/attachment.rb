class Attachment < ActiveRecord::Base

  has_attached_file :data,
                    :path => ":rails_root/upload/:attachment/:id/:style/:filename",
                    :processors => lambda { |a|
                                            if a.image?
                                              [:thumbnail]
                                            elsif a.notebook?
                                              [:noise_airport_kml_processor]
                                            else
                                              []
                                            end
                                          },
                    :styles => lambda { |a|
                                        if a.instance.image?
                                          { :small  => ["100x100>"], 
                                            :medium => ["800x800>"] }
                                        elsif a.notebook?
                                          {}
                                        else 
                                          {}
                                        end
                                      }

  before_post_process :before_post_process
  after_post_process :after_post_process

  def before_post_process
    puts "=== Before processing #{File.basename(data.path)} ==========="
  end
  
  def after_post_process
    puts "--- After processing #{File.basename(data.path)} ------------"
  end

  belongs_to :container, :polymorphic => true
  belongs_to :study, foreign_key: 'container_id', conditions: "attachments.container_type = 'Study'"

  validates_attachment_presence :data
  validates_attachment_size     :data, :less_than => 100.megabytes

  def image?
    return false unless data.content_type
    data.content_type =~ /^image/
  end 

  def notebook?
    return false unless data.content_type
    data.content_type =~ /google-earth\.kml/
  end 

  def text?
    return false unless data.content_type
    data.content_type =~ /^text/
  end 

end
