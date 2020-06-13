# frozen_string_literal: true

module LayoutHelper
  include WhatsOpt::Version

  def deployment_info
    flagfile = "#{Rails.root}/tmp/restart.txt"
    if File.exist?(flagfile)
      "deployed: #{File.atime(flagfile).strftime("%Y-%m-%d at %H:%M")}"
    else
      ""
    end
  end
end
