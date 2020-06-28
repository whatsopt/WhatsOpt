class DesignProjectsController < ApplicationController

  # GET /mdas
  def index
    @projects = policy_scope(DesignProject)
  end

  # GET /mdas/1
  def show
  end

  # POST /mdas
  def create
  end

end
