class Api::V1::StudiesController < Api::ApiController 

  def index
    @studies = Study.all
    respond_with @studies
  end
 
end
