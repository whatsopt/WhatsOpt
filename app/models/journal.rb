# frozen_string_literal: true

class Journal < ApplicationRecord

  belongs_to :analysis
  belongs_to :user
  has_many :details, class_name: "JournalDetail", dependent: :destroy

  ADD_ACTION = :add
  CHANGE_ACTION = :change 
  REMOVE_ACTION = :remove
  ACTIONS = [ADD_ACTION, CHANGE_ACTION, REMOVE_ACTION] 

  def journalize_discipline(disc, action)
    key = (action == REMOVE_ACTION ? :old_value : :value)
    details <<
      JournalDetail.new(
        entity_type: 'Discipline',
        entity_id: disc.id,
        entity_attr: "name",
        action: action,
        key => disc.name
      )
  end

  def journalize_discipline_changes(disc, old_attrs)
    disc.journalized_attribute_names.each do |attr_name|
      before = old_attrs[attr_name]
      after = disc.send(attr_name)
      unless before == after || (before.blank? && after.blank?)
        add_change_detail('Discipline', disc.id, attr_name, before, after)
      end
    end
  end

  def add_change_detail(entity_type, entity_id, entity_attr, old_value, value)
    details <<
      JournalDetail.new(
        entity_type: entity_type,
        entity_id: entity_id,
        entity_attr: entity_attr,
        action: CHANGE_ACTION,
        old_value: old_value,
        value: value
      )
  end
end