namespace :whatsopt do
  namespace :delivery do
  
    def version(v)
      if (v =~ /(\d+).(\d+).(\d+)/)
        major=$1
        minor=$2
        patch=$3
        tag = "#{$1}.#{$2}.#{$3}"
        return major, minor, patch, tag
      else
        puts "Bad version number '#{v}'. Abort"
        exit -1
      end 
    end
  
    DLVDIR="~/DELIVERY"
    EXPORT="#{DLVDIR}/export"
  
    desc 'Pack of TEIS web application delivery'
    task :pack, [:version] do |t, args|
      (major, minor, patch, tag) = version(args[:version])
      basename   = "whatsopt-#{major}.#{minor}.#{patch}"
      repository = "ssh://designlab@endymion/d/designlab/gitrepos/WhatsOpt.git"
      tagpath = "#{repository}/tags/#{tag}"
      sh "rm -rf #{EXPORT}"
      sh "rm -f #{DLVDIR}/#{basename}.tar.gz"
      sh "git clone #{repository} #{EXPORT}/#{tag} --branch #{tag}"
      sh "git archive -o #{DLVDIR}/#{basename}.tar.gz #{tag}"
      sh "rm -rf #{EXPORT}"
    end
  
    desc 'Unpack of TEIS web application delivery'
    task :unpack, [:version] do |t, args|
      (major, minor, patch, tag) = version(args[:version])
      basename = "whatsopt-#{major}.#{minor}.#{patch}"
      sh "rm -rf #{DLVDIR}/#{basename}"
      sh "tar xvfz #{DLVDIR}/#{basename}.tar.gz"
    end
  end
end