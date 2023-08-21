# frozen_string_literal: true

class JournalSerializer < ActiveModel::Serializer
  attributes :author, :created_on
  has_many :details

  def author
    object.user.login
  end
end
