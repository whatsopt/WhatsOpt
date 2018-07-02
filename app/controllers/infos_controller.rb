class InfosController < ApplicationController
  
  def changelog
    authorize :info
  end
  
end