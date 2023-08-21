APP_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/configuration.yml")).result)[Rails.env]
