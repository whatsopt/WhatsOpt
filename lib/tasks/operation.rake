namespace :whatsopt do
  namespace :operation do

    desc "Set default success field to true"
    task :set_success => :environment do
      Operation.all.each do |ope|
        if ope.cases.count == 0
          ope.success = []
        elsif ope.success.blank? 
          ope.success = Array.new(ope.cases[0].values.size, 1)
        else
          ope.success = ope.success.map{|s| (s==1 or s==true) ? 1 : 0}
        end
        puts "set ope #{ope.id} #{ope.name} success with #{ope.success}"
        ope.save!
      end
    end

  end
end
