# frozen_string_literal: true

require "devise/strategies/authenticatable"

module Devise
  module Strategies
    class LocalOverride < Authenticatable
      def valid?
        true
      end

      def authenticate!
        if params[:user]
          user = User.find_by_login(params[:user][:login])
          if user
            if user.valid_password?(params[:user][:password])
              success!(user)
            else
              halt!
            end
          else
            fail
          end
        else
          halt!
        end
      end
    end
  end
end

Warden::Strategies.add(:local_override, Devise::Strategies::LocalOverride)
