# frozen_string_literal: true

require "active_model_serializers"
ActiveModelSerializers.logger = Logger.new(nil)

# WARNING: should avoid recursive def => avoid defining has_* AND belongs_to in serializers. We define only has_*
ActiveModel::Serializer.config.default_includes = "**" # (default '*')
