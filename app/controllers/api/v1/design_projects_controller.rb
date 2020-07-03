# frozen_string_literal: true

class Api::V1::DesignProjectsController < Api::ApiController
  # GET /api/v1/users
  def index
    json_response policy_scope(DesignProject)
  end
end
