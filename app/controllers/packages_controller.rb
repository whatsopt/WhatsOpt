# frozen_string_literal: true

class PackagesController < ApplicationController

  # GET /packages
  def index
    @packages = policy_scope(Package)
  end

end
