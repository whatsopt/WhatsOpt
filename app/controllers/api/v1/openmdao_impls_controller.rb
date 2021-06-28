# frozen_string_literal: true

class Api::V1::OpenmdaoImplsController < Api::ApiController
  def show
    mda = Analysis.find(params[:mda_id])
    authorize mda
    @impl = mda.openmdao_impl ||= OpenmdaoAnalysisImpl.new
    json_response @impl
  end

  # PUT/PATCH /api/v1/analysis/{mda_id}/openmdao_analysis_impl
  def update
    mda = Analysis.find(params[:mda_id])
    authorize mda
    @impl = mda.openmdao_impl ||= OpenmdaoAnalysisImpl.new
    @impl.update_impl(impl_params)
    @impl.save!
    head :no_content
  end

  private
    def impl_params
      params.require(:openmdao_impl).permit(components: [:parallel_group, :use_units, nodes: [[:discipline_id, :implicit_component, :support_derivatives]]],
                                            nonlinear_solver: [:name, :atol, :rtol, :maxiter, :err_on_non_converge, :iprint],
                                            linear_solver: [:name, :atol, :rtol, :maxiter, :err_on_non_converge, :iprint])
    end
end
