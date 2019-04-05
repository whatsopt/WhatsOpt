class OpenmdaoDisciplineImplSerializer < ActiveModel::Serializer
  attributes :discipline_id, :implicit_component, :support_derivatives 
end