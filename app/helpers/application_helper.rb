# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
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

  def enable_wopstore?
    APP_CONFIG["enable_wopstore"]
  end

  def enable_remote_operations?
    APP_CONFIG["enable_remote_operations"]
  end

  def restricted_access?
    APP_CONFIG["restrict_access"]
  end
end
