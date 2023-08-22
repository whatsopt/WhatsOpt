# frozen_string_literal: true

module UsersHelper
  def is_user_setting?(key, value)
    if current_user.settings[key]
      (current_user.settings[key] == value)
    else  # default
      if key == "analyses_query"
        "all" == value
      elsif key == "analyses_order"
        "oldest" == value
      else
        raise "User setting key '#{key}' is unknown (should be either analyses_query or analyses_order)"
      end
    end
  end
end
