# frozen_string_literal: true

class DistributionSerializer < ActiveModel::Serializer
  attributes :id, :kind

  has_many :options, key: :options_attributes
end
