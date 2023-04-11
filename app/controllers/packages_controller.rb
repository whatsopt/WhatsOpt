# frozen_string_literal: true

class PackagesController < ApplicationController

  # GET /packages
  def index
    @packages = policy_scope(Package)
  end

  # DELETE /packages/1
  def destroy
    @package = Package.find(params[:id])
    name = @package.archive.attachment.filename
    authorize @package
    @package.destroy
    redirect_to packages_url, notice: "Package #{name} was successfully deleted."
  end

  private 

  def package_params
    params.require(:package).permit(:description, :archive) 
  end

end
