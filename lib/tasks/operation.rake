# frozen_string_literal: true

namespace :whatsopt do
  namespace :operation do
    desc "Set default success field to true"
    task set_success: :environment do
      Operation.all.each do |ope|
        if ope.cases.count == 0
          ope.success = []
        elsif ope.success.blank?
          ope.success = Array.new(ope.cases[0].values.size, 1)
        else
          ope.success = ope.success.map { |s| ((s == 1) || (s == true)) ? 1 : 0 }
        end
        puts "set ope #{ope.id} #{ope.name} success with #{ope.success}"
        ope.save!
      end
    end

    desc "Set created_at/update_at to started_at or analysis.created_at/updated_at"
    task set_timestamps: :environment do
      Operation.all.each do |ope|
        timestamp = if ope.job && !ope.job.started_at.blank?
          ope.job.started_at
        else
          ope.analysis.created_at
        end
        puts "Set '#{ope.name}' at #{timestamp}"
        ope.update_column(:created_at, timestamp)
        ope.update_column(:updated_at, timestamp)
      end
    end

    desc "Set operation as optionizable"
    task set_optionizable: :environment do |ope|
      Operation.all.each do |ope|
        ope.options.each do |opt|
          puts "Set #{ope.name}' for option '#{opt.name}' as optionizable"
          opt.update_column(:optionizable_id, opt.operation_id)
          opt.update_column(:optionizable_type, "Operation")
        end
      end
    end
  end
end
