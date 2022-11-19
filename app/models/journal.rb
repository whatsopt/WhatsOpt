# frozen_string_literal: true

class Journal < ApplicationRecord

  belongs_to :analysis
  belongs_to :user
  has_many :details, class_name: "JournalDetail", dependent: :delete_all

  ADD_ACTION = :add
  CHANGE_ACTION = :change 
  REMOVE_ACTION = :remove
  COPY_ACTION = :copy
  ACTIONS = [ADD_ACTION, CHANGE_ACTION, REMOVE_ACTION, COPY_ACTION] 

  def save(*args)
    details.empty? ? false : super()
  end

  def journalize(journalized, action, copy_what: nil)
    key = (action == REMOVE_ACTION ? :old_value : :value)
    details <<
      JournalDetail.new(
        entity_type: journalized.class.name,
        entity_name: journalized.name,
        entity_attr: "name",
        action: action,
        key => "#{journalized.name}#{copy_what}"
      )
  end

  def journalize_changes(journalized, old_attrs)
    journalized.journalized_attribute_names.each do |attr_name|
      before = old_attrs[attr_name]
      after = journalized.send(attr_name)
      unless before == after || (before.blank? && after.blank?)
        # Ensure value size less than 255 characters which correspond to field string max size in db 
        before = before.truncate(30)
        after = after.truncate(30)
        add_change_detail(journalized.class.name, journalized.name, attr_name, before, after)
      end
    end
  end

  def add_change_detail(entity_type, entity_name, entity_attr, old_value, value)
    details <<
      JournalDetail.new(
        entity_type: entity_type,
        entity_name: entity_name,
        entity_attr: entity_attr,
        action: CHANGE_ACTION,
        old_value: old_value,
        value: value
      )
  end
end