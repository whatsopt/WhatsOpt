# frozen_string_literal: true

class PackagesController < ApplicationController

  # GET /packages
  def index
    @packages = policy_scope(Package)
  end

  # GET /packages/new
  def new
    @package = Package.new
    authorize @package
  end

  # GET /packages/1/edit
  def edit
  end

  # POST /packages
  def create
    @package = Package.new(package_params)
    authorize @package
    if params[:cancel_button]
      redirect_to packages_url, notice: "Package creation cancelled."
    else
      if @package.save
        redirect_to packages_url, notice: "Package #{@package.id} was successfully created."
      else
        redirect_to new_package_url, error: "Something went wrong."
      end
    end
  end

  private 

  def package_params
    params.require(:package).permit(:description, :archive) 
  end

end
