module LayoutHelper
  
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
