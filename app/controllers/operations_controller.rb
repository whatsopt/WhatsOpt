# frozen_string_literal: true

class OperationsController < ApplicationController
  before_action :set_ope, only: [:show, :destroy]

  # GET /analyses/:mda_id/operations
  def index
    @mda = Analysis.find(params[:mda_id])
    @operations = policy_scope(Operation).done(@mda)
  end

  # GET /operations/1
  def show
    @mda = @ope.analysis
  end

  # DELETE /operations/1
  def destroy
    authorize @ope
    @ope.destroy
    redirect_to mdas_url, notice: "Operation was successfully destroyed."
  rescue Operation::ForbiddenRemovalError => exc
    redirect_to mdas_url, alert: exc.message
  end

  private
    def set_ope
      @ope = Operation.find(params[:id])
      authorize @ope
    end
end
