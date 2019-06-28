# frozen_string_literal: true

require "highline"

namespace :whatsopt do
  namespace :access do
    desc "Create user accounts with rake, prompting for user name and password."
    task user: :environment do
      ui = HighLine.new
      login    = ui.ask("Login: ")
      email    = ui.ask("Email: ")
      password = ui.ask("Enter password: ") { |q| q.echo = false }
      confirm  = ui.ask("Confirm password: ") { |q| q.echo = false }

      user = User.new(email: email, login: login, password: password, password_confirmation: confirm)
      if user.save
        puts "User account '#{login}' created."
      else
        puts "Problem creating user account:"
        puts user.errors.full_messages
      end
    end
  end
end
