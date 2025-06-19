# frozen_string_literal: true

module ApplicationHelper

  def logo_svg()
    image_svg = if restricted_access?
      "logo_whatsopt_kaki_v1.0.svg"
    elsif Rails.env.production?
      "logo_whatsopt_v1.0.svg"
    else
      "logo_whatsopt_yellow_v1.0.svg"
    end
    image_tag("#{image_svg}", alt: "Logo", width: 32, height: 32, class: "d-inline-block align-top")
  end

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
