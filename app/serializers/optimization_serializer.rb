# frozen_string_literal: true

class OptimizationSerializer < ActiveModel::Serializer
  attributes :id, :kind, :config, :inputs, :outputs, :created_at, :updated_at

  # Workaround!
  # store json field named 'config' (store a hash as a json string) and serialization does not seem to work properly
  # Actually it is due to a name clash, 'config' method exists in OptimizationSerializer object
  # I found out with
  # def kind
  #   p method(:config)
  #   p config
  #   object.kind
  # end
  # which yields:
  # ActiveModel#<Method: OptimizationSerializer(ActiveSupport::Configurable)#config() /home/rlafage/.rbenv/versions/3.0.3/lib/ruby/gems/3.0.0/gems/activesupport-7.0.3.1/lib/active_support/configurable.rb:145>
  # #< {}>
  #
  # to make it work I override here the attribute with a custom method which return the right object
  def config
    object.config
  end
end
