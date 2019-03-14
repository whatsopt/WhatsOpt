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
  
  def intranet?
    return APP_CONFIG['intranet']
  end

end
