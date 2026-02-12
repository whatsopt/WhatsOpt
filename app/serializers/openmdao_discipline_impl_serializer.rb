# frozen_string_literal: true

class OpenmdaoDisciplineImplSerializer < ActiveModel::Serializer
  attributes :discipline_id, :implicit_component, :support_derivatives, :egmdo_surrogate, :jax_component
end
