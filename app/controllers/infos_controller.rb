# frozen_string_literal: true

class InfosController < ApplicationController
  def changelog
    authorize :info
  end
end
