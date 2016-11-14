class Api::V1::StudiesController < Api::ApiController 

  # GET /studies
  def index
    @studies = Study.all
    respond_with @studies
  end

  # POST /studies
  def create
    @study = Study.create(study_params)
    respond_with @study
  end

  private

  def study_params
    # FIXME: should validate the tree and conns jsons
    # Can not use string parameters as is for tree structure is recursive
    params.require(:study).permit!
  end
  
end
