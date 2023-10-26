# frozen_string_literal: true

APP_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/configuration.yml")).result, aliases: true)[Rails.env]
