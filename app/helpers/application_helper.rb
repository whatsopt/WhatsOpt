module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger",
      alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages
    h = {}
    [:success, :error, :alert, :notice].each do |k|
      h[k] = flash[k] unless flash[k].blank?
    end
    h
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s+"/"+association.to_s.singularize + "_fields", :f => builder)
    end
    link_to name, '#' , class: "add-fields", "data-association": "#{association}", "data-content": "#{fields}"
  end

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
  
end
