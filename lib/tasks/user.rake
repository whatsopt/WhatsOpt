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

    desc "Deactivate users whose login or email matches a given substring."
    task deactivate: :environment do
      ui = HighLine.new
      pattern = ui.ask("Enter substring to match login or email: ")

      users = User.where("login LIKE :pat OR email LIKE :pat", pat: "%#{pattern}%").where(deactivated: [false, nil])
      if users.empty?
        puts "No active users found matching '#{pattern}'."
        next
      end

      fmt = "%-20s %-35s %-12s %-12s %-12s"
      puts "\nThe following active users match '#{pattern}':"
      puts fmt % ["LOGIN", "EMAIL", "STATUS", "CREATED", "LAST SIGN-IN"]
      puts "-" * 95
      users.each do |u|
        created = u.created_at&.strftime("%Y-%m-%d") || "-"
        last_sign_in = u.last_sign_in_at&.strftime("%Y-%m-%d") || "-"
        puts fmt % [u.login, u.email, "active", created, last_sign_in]
      end
      puts ""

      confirm = ui.agree("Deactivate these #{users.count} user(s)? (yes/no) ")
      if confirm
        count = users.update_all(deactivated: true)
        puts "#{count} user(s) deactivated."
      else
        puts "Aborted."
      end
    end

    desc "Activate (reactivate) users whose login or email matches a given substring."
    task activate: :environment do
      ui = HighLine.new
      pattern = ui.ask("Enter substring to match login or email: ")

      users = User.where("login LIKE :pat OR email LIKE :pat", pat: "%#{pattern}%").where(deactivated: true)
      if users.empty?
        puts "No deactivated users found matching '#{pattern}'."
        next
      end

      fmt = "%-20s %-35s %-12s %-12s %-12s"
      puts "\nThe following deactivated users match '#{pattern}':"
      puts fmt % ["LOGIN", "EMAIL", "STATUS", "CREATED", "LAST SIGN-IN"]
      puts "-" * 95
      users.each do |u|
        created = u.created_at&.strftime("%Y-%m-%d") || "-"
        last_sign_in = u.last_sign_in_at&.strftime("%Y-%m-%d") || "-"
        puts fmt % [u.login, u.email, "deactivated", created, last_sign_in]
      end
      puts ""

      confirm = ui.agree("Activate these #{users.count} user(s)? (yes/no) ")
      if confirm
        count = users.update_all(deactivated: false)
        puts "#{count} user(s) activated."
      else
        puts "Aborted."
      end
    end

    desc "List all users (login, email, status, creation date, last sign-in date)."
    task list: :environment do
      users = User.order(:login)
      if users.empty?
        puts "No users found."
        next
      end

      fmt = "%-20s %-35s %-12s %-12s %-12s"
      puts fmt % ["LOGIN", "EMAIL", "STATUS", "CREATED", "LAST SIGN-IN"]
      puts "-" * 95
      users.each do |u|
        status = u.deactivated ? "deactivated" : "active"
        created = u.created_at&.strftime("%Y-%m-%d") || "-"
        last_sign_in = u.last_sign_in_at&.strftime("%Y-%m-%d") || "-"
        puts fmt % [u.login, u.email, status, created, last_sign_in]
      end
      puts "\nTotal: #{users.count} user(s)"
    end
  end
end
