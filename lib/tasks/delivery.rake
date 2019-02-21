namespace :whatsopt do
  namespace :delivery do

    DLVDIR= "~/DELIVERY"
    EXPORT= "#{DLVDIR}/export"
  
    desc 'Pack of TEIS web application delivery'
    task :pack, [:version] do |t, args|
      tag = args[:version]
      if (tag == 'HEAD')
        puts "Packing WhatsOpt latest..."
      else
        puts "Packing WhatsOpt #{tag}..."
      end
      basename   = "whatsopt-#{tag}"
      repository = "ssh://designlab@endymion/d/designlab/gitrepos/WhatsOpt.git"
      sh "rm -rf #{EXPORT}"
      sh "rm -f #{DLVDIR}/#{basename}.tar.gz"
      sh "git clone --recursive #{repository} #{EXPORT}/#{tag} --branch #{tag}"
      #sh "git archive -o #{DLVDIR}/#{basename}.tar.gz #{tag}"
      # Use git-archive-all : https://pypi.org/project/git-archive-all/
      sh "cd #{EXPORT}/#{tag}; git-archive-all --prefix='' #{DLVDIR}/#{basename}.tar.gz"
      sh "rm -rf #{EXPORT}"
    end
  
    desc 'Unpack of TEIS web application delivery'
    task :unpack, [:version] do |t, args|
      tag = args[:version]
      basename = "whatsopt-#{tag}"
      sh "rm -rf #{DLVDIR}/#{basename}"
      sh "tar xvfz #{DLVDIR}/#{basename}.tar.gz"
    end
  end
end