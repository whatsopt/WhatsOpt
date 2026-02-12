# frozen_string_literal: true

namespace :whatsopt do
  namespace :cleanup do
    # Order matters: sensitivity operations depend on metamodel operations,
    # so they must be deleted first to avoid foreign key issues.
    METAMODEL_DRIVERS = %w[
      openturns_sensitivity_pce
      openturns_metamodel_pce
      smt_metamodel_kriging
    ].freeze

    desc "Remove operations related to metamodel (drivers: #{METAMODEL_DRIVERS.join(', ')})"
    task metamodel_operations: :environment do
      operations = Operation.where(driver: METAMODEL_DRIVERS).order(Arel.sql(
        "CASE driver " +
        METAMODEL_DRIVERS.each_with_index.map { |d, i| "WHEN '#{d}' THEN #{i}" }.join(" ") +
        " END"
      ))
      count = operations.count
      if count == 0
        puts "No metamodel-related operations found."
      else
        puts "Found #{count} metamodel-related operation(s):\n\n"
        operations.find_each do |ope|
          owner = ope.analysis.owner&.email || "unknown"
          puts "  - Operation ##{ope.id} '#{ope.name}' (driver: #{ope.driver}, analysis: #{ope.analysis.name}, owner: #{owner})"
        end
        print "\nAre you sure you want to delete these #{count} operation(s)? [y/N] "
        confirmation = $stdin.gets.chomp
        if confirmation.downcase == "y"
          operations.destroy_all
          puts "Deleted #{count} metamodel-related operation(s)."
        else
          puts "Aborted."
        end
      end
    end
  end
end
