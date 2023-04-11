# frozen_string_literal: true

class Api::V1::PackagesController < Api::ApiController

  # POST /api/v1/{mda_id}/package
  def create
    @mda = Analysis.find(params[:mda_id])
    authorize @mda
    @package = @mda&.package 
    if @package
      @package.update(package_params)
    else
      @package = Package.new(package_params)
    end
    @package.analysis = @mda
    @package.save!
    render json: @package, status: :created
  end

  private 

  def package_params
    params.require(:package).permit(:description, :archive) 
  end

end
