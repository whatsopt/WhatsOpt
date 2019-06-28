# frozen_string_literal: true

module UsersHelper
  def is_user_setting?(key, value)
    if current_user.settings[key]
      (current_user.settings[key] == value)
    else
      if key == "analyses_query"
        "all" == value
      else
        false
      end
    end
  end
end
