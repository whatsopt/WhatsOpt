# frozen_string_literal: true

class EndpointSerializer < ActiveModel::Serializer
  attributes :id, :host, :port
end
