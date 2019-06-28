# frozen_string_literal: true

class ConnectionSerializer < ActiveModel::Serializer
  attributes :id, :from, :to
end
