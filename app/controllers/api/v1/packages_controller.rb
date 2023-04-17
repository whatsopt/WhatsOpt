# frozen_string_literal: true

class Api::V1::PackagesController < Api::ApiController
  before_action :set_package

  # GET /api/v1/{mda_id}/package
  def show
    if @package
      render json: @package, status: :created
    else
      render json: { message: "No package" }, status: :not_found
    end
  end

  # POST /api/v1/{mda_id}/package
  def create
    if @package
      authorize @package, :update?
      @package.update(package_params)
    else
      @package = Package.new(package_params)
    end
    @package.analysis = @mda
    @package.save!
    render json: @package, status: :created
  end

  private 

  def set_package
    @mda = Analysis.find(params[:mda_id])
    authorize @mda
    @package = @mda&.package
    authorize @package if @package
  end

  def package_params
    params.require(:package).permit(:description, :archive) 
  end

end
