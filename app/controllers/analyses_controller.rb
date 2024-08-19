# frozen_string_literal: true

class AnalysesController < ApplicationController
  include Pagy::Backend

  before_action :set_mda, only: [:show, :edit, :destroy]
  after_action :save_journal, only: [:create]

  # GET /mdas
  def index
    if params[:design_project_id]
      policy_scope(DesignProject)
      @design_project = DesignProject.find(params[:design_project_id])
      current_user.update(analyses_scope_design_project_id: @design_project.id)
      redirect_to mdas_url
    else
      @mdas = policy_scope(Analysis)
      if current_user.analyses_query == "mine"
        @mdas = @mdas.owned_by(current_user)
      end
      if current_user.analyses_order == "newest"
        @mdas = @mdas.newest
      end
      unless current_user.analyses_filter.blank?
        if current_user.analyses_filter.start_with?("by:")
          user = User.find_by_login(current_user.analyses_filter[3..-1])
          if user  # User is found then filter
            @mdas = @mdas.owned_by(user)
          else     # otherwise just return empty scope
            @mdas = @mdas.none
          end
        else
          @mdas = @mdas.name_starts_with(current_user.analyses_filter)
        end
      end
      unless current_user.analyses_scope_design_project_id.blank?
        @mdas = @mdas.joins(:design_project_filing)
          .where(design_project_filings: { design_project_id: current_user.analyses_scope_design_project_id })
      end
      @pagy, @mdas = pagy(@mdas)
    end
  end

  # GET /mdas/1
  def show
  end

  # GET /mdas/new
  def new
    @mda = Analysis.new
    authorize @mda
  end

  # POST /mdas
  def create
    if params[:cancel_button]
      skip_authorization
      redirect_to mdas_url, notice: "Analysis creation cancelled."
    else
      if params[:mda_id]
        @orig_mda = Analysis.find(params[:mda_id])
        authorize @orig_mda
        @mda = @orig_mda.create_copy!
        action = Journal::COPY_ACTION
      else
        @mda = Analysis.new(mda_params)
        authorize @mda
        action = Journal::ADD_ACTION
      end
      if @mda.save
        @journal = @mda.init_journal(current_user)
        @journal.journalize(@mda, action)
        @mda.set_owner(current_user)
        @mda.copy_membership(@orig_mda) unless !@orig_mda || @orig_mda.public
        if @mda.disciplines.nodes.empty?
          redirect_to edit_mda_url(@mda)
        else
          redirect_to mda_url(@mda), notice: "Analysis #{@mda.name} was successfully created."
        end
      elsif params[:mda_id]
        redirect_to mda_url(Analysis.find(params[:mda_id])), error: "Something went wrong while copying #{@orig_mda.name}."
      else
        @import = params[:import]
        render :new
      end
    end
  end

  # DELETE /mdas/1
  def destroy
    if @mda.parent
      redirect_to mdas_url, alert: "Can not delete nested analysis (you should delete parent first)."
    else
      unless @mda.operations.blank? # remove operations in reverse order first
        @mda.operations.reverse_each { |ope| ope.destroy! }
      end
      @mda.destroy!
      redirect_to mdas_url, notice: "Analysis #{@mda.name} was successfully deleted."
    end
  rescue Discipline::ForbiddenRemovalError => exc
    redirect_to mdas_url, alert: "Can not delete analysis #{@mda.name}, reason: " + exc.message
  rescue Operation::ForbiddenRemovalError => exc
    redirect_to mdas_url, alert: "Can not delete analysis #{@mda.name}, reason: " + exc.message
  end

  private
    def set_mda
      @mda = Analysis.find(params[:id])
      authorize @mda
      @journal = @mda.init_journal(current_user)
    end

    def mda_params
      params.require(:analysis).permit(:name, :public, :locked, design_project: [:id])
    end

    def save_journal
      @mda.save_journal if @mda  # analysis may not exist when cancelling analysis creation
    end
end
