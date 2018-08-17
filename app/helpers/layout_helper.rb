module LayoutHelper
  
# DEPRECATED: UNUSED?
#  def title(page_title, show_title = true)
#    content_for(:title) { page_title.to_s }
#    @content_for_title = page_title.to_s
#    @show_title = show_title
#  end
#  
#  def show_title?
#    @show_title
#  end
#  
#  def stylesheet(*args)
#    content_for(:head) { stylesheet_link_tag(*args) }
#  end
#  
#  def javascript(*args)
#    content_for(:head) { javascript_include_tag(*args) }
#  end
#
#  def bootstrap_version
#    "3.1.1"
#  end
#
  
  def version_major  
    File.read(File.expand_path("VERSION", Rails.root)) =~ /(\d+)\.(\d+)\.(\d+)/
    $1
  end
  def version_minor 
    File.read(File.expand_path("VERSION", Rails.root)) =~ /(\d+)\.(\d+)\.(\d+)/
    $2
  end
  def version_patch   
    File.read(File.expand_path("VERSION", Rails.root)) =~ /(\d+)\.(\d+)\.(\d+)/
    $3    
  end
  def version_release 
    File.read(File.expand_path("VERSION", Rails.root)) =~ /(\d+)\.(\d+)\.(\d+)\-(\d+)/
    $4
  end
  
  def version
    v = "#{version_major}.#{version_minor}.#{version_patch}"
    v << "-#{version_release}" unless version_release=="0" or version_release.blank?
    v
  end
end
