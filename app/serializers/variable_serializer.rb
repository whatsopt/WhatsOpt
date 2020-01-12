# frozen_string_literal: true

class VariableSerializer < ActiveModel::Serializer
  attributes :name, :io_mode, :shape, :type, :desc, :units, :active

  has_one :parameter, key: :parameter_attributes
  has_one :scaling, key: :scaling_attributes
  has_one :distribution, key: :distribution_attributes

  def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
    hash = super
    hash.each { |key, value| hash.delete(key) if value.nil? }
    hash
  end

end
