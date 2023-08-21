# frozen_string_literal: true

class Api::V1::OpenmdaoImplsController < Api::V1::ApiMdaUpdaterController
  after_action :touch_mda, only: [ :update ]

  def show
    @mda = Analysis.find(params[:mda_id])
    authorize @mda
    @impl = @mda.openmdao_impl || OpenmdaoAnalysisImpl.new(analysis: @mda)
    json_response @impl
  end

  # PUT/PATCH /api/v1/analysis/{mda_id}/openmdao_analysis_impl
  def update
    @mda = Analysis.find(params[:mda_id])
    check_mda_update
    authorize @mda
    @impl = @mda.openmdao_impl || OpenmdaoAnalysisImpl.new(analysis: @mda)
    @impl.update_impl(impl_params)
    @impl.save!
    head :no_content
  end

  private
    def impl_params
      params.require(:openmdao_impl).permit(:parallel_group, :use_units, :optimization_driver,
                                            packaging: [:package_name],
                                            nodes: [[:discipline_id,
                                                     :implicit_component,
                                                     :support_derivatives,
                                                     :egmdo_surrogate]],
                                            nonlinear_solver: [:name, :atol, :rtol, :maxiter, :err_on_non_converge, :iprint],
                                            linear_solver: [:name, :atol, :rtol, :maxiter, :err_on_non_converge, :iprint])
    end
end
