# frozen_string_literal: true

namespace :db do
  desc "sanity check WhatsOptdatabase content"
  task check_connections: :environment do
    puts "Connections"
    puts "-----------"
    Connection.all.each do |conn|
      if conn.from.nil?
        puts "Connection #{conn.id} has dangling 'from' end: var #{conn.from_id}"
        if conn.to.nil?
          puts "Connection #{conn.id} has dangling 'to' end: var #{conn.to_id}"
        else
          puts "Connection #{conn.id} is connected to #{conn.to.name} from " +
               " discipline #{conn.to.discipline.name} from analysis #{conn.to.discipline.analysis.name}"
        end
      end
      if conn.to.nil?
        puts "Connection #{conn.id} has dangling from end: var #{conn.to_id}"
        puts "Connection #{conn.id} is connected to #{conn.from.name} from " +
             "discipline #{conn.from.discipline.name} from analysis #{conn.from.discipline.analysis.name}"
      end
    end
    puts "-----------------------------------------------------------------------"
  end

  task check_variables: :environment do
    puts "Variables"
    puts "---------"
    Variable.all.each do |var|
      if var.discipline.nil?
        puts "Variable #{var.inspect} is orphan"
      end
      if Connection.where("from_id = ? OR to_id = ?", var.id, var.id).empty?
        puts "Variable #{var.name}(#{var.id}) from discipline #{var.discipline.name} " +
             "from analysis #{var.discipline.analysis.name} is not connected"
      end
    end
    puts "-----------------------------------------------------------------------"
  end

  task check: :environment do
    Rake::Task["db:check_connections"].invoke
    Rake::Task["db:check_variables"].invoke
  end
end
