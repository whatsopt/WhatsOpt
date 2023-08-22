# frozen_string_literal: true

class JournalDetailSerializer < ActiveModel::Serializer
  attributes :entity_type, :entity_attr, :entity_name, :action, :old_value, :value
end
