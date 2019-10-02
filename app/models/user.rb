# frozen_string_literal: true

class User < ActiveRecord::Base
  rolify strict: true

  devise :database_authenticatable
  devise :ldap_authenticatable if APP_CONFIG["ldap"]
  devise :trackable, :validatable, :timeoutable
  # devise :ldap_authenticatable, :trackable, :validatable, :timeoutable

  after_initialize :initialize_defaults, if: :new_record?
  before_create :generate_api_key

  store :settings, accessors: [:analyses_query], coder: JSON

  # work around rolify with_role method bug: see https://github.com/RolifyCommunity/rolify/issues/362
  scope :with_role_for_instance, lambda { |role_name, instance|
    resource_name = instance.class.name

    joins(:roles).where(roles: {
                          name: role_name.to_s,
                          resource_type: resource_name,
                          resource_id: instance.id
                        })
  }

  # Used to create user on first LDAP authentication
  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(login, "mail").first
  end

  def admin?
    has_role?(:admin)
  end

  private
    def generate_api_key
      begin
        self.api_key = SecureRandom.hex
      end while self.class.exists?(api_key: api_key)
    end

    def initialize_defaults
      add_role(:user)
      self.analyses_query = "all"
    end
end
