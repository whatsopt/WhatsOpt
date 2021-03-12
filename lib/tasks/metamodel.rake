namespace :whatsopt do
  namespace :metamodels do
    desc "Force retrain metamodel"
    task retrain: :environment do
      MetaModel.all.each do |mm|
        puts "Train #{mm.analysis.name}(#{mm.analysis.id}) metamodel##{mm.id}"
        mm.train
      end
    end
  end
end