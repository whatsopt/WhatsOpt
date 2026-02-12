# frozen_string_literal: true

class User < ActiveRecord::Base

  class RestrictedServerException < StandardError; end

  rolify strict: true

  devise :database_authenticatable
  devise :ldap_authenticatable if APP_CONFIG["enable_ldap"]
  devise :trackable, :validatable, :timeoutable, :recoverable

  has_many :journals, dependent: :destroy

  validates :login, :email, presence: true
  validate :password_complexity, on: :update  # Only used by devise on password reset by the user

  after_initialize :initialize_defaults, if: :new_record?
  before_create :generate_api_key

  store :settings, accessors: [:analyses_query, :analyses_order, :analyses_filter, :analyses_scope_design_project_id], coder: JSON

  # work around rolify with_role method bug: see https://github.com/RolifyCommunity/rolify/issues/362
  scope :with_role_for_instance, lambda { |role_name, instance|
    resource_name = instance.class.name

    joins(:roles).where(roles: {
                          name: role_name.to_s,
                          resource_type: resource_name,
                          resource_id: instance.id
                        })
  }

  # Backward-compatibility WhatsOpt < 1.13
  # Use save not save! (update not update!) to avoid exception due to password
  # complexity validation failure now because we have stronger conditions for password on reset (ie on update)
  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-;])/
    errors.add :password, "Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character (#?!@$%^&*-;)"
  end

  # Used to create user on first LDAP authentication
  def ldap_before_save
    if !restricted_access? || need_to_know_expert?
      self.email = Devise::LDAP::Adapter.get_ldap_param(login, "mail").first
    else 
      raise RestrictedServerException, "You are not authorized to access this server."
    end
  end

  def admin?
    @admin ||= has_role?(:admin)
  end

  def need_to_know_expert?
    @need_to_know_expert ||= has_role?(:need_to_know_expert)
    if !@need_to_know_expert && APP_CONFIG["enable_ldap"]
      @unit ||= Devise::LDAP::Adapter.get_ldap_param(login, "ou")&.first
      @need_to_know_expert ||= (@unit == "DTIS/CASH" || @unit == "DTIS/CSAM" || @unit == "DTIS/MARS")
    end
    @need_to_know_expert
  end

  def reset_api_key!
    generate_api_key
    save
  end

  def active_for_authentication?
    super && !deactivated && (!restricted_access? || need_to_know_expert? || admin?)
  end

  def destroy
    update(deactivated: true) unless deactivated
  end

  def destroy!
    update!(deactivated: true) unless deactivated
  end

  def name_from_email
    email =~ /(.*)@.*/
    name = $1
    if name =~ /(\w+)\.(\w+)/
      name = "#{$1.capitalize} #{$2.capitalize}"
    end
    name
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
      self.analyses_scope_design_project_id = nil
    end

    def restricted_access?
      APP_CONFIG["restrict_access"]
    end
end
