module Api::V1::Concerns::Docs::AnalysesController
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks
    swagger_path "/analyses" do
      operation :get do
        extend Api::V1::Concerns::Docs::ErrorResponses::AuthenticationError

        key :summary, 'List analyses'
        key :description, 'Returns the list of analyses the user have read access on'
        key :operationId, 'findAnalyses'
        key :tags, ['Analyses']
        security Token: []

        response 200 do
          key :description, 'Analyses response'
          schema type: :array do
            items do
              key :'$ref', :Analysis
            end
          end
        end
      end
    end

    swagger_path "/analyses/{id}" do
      operation :get do
        extend Api::V1::Concerns::Docs::ErrorResponses::AuthenticationError

        key :summary, 'Find analysis by id'
        key :description, 'Returns the analysis specified with given id'
        key :tags, ['Analyses']
        security Token: []

        parameter do
          key :name, :id
          key :in, :path
          key :description, 'Analysis identifier'
          key :required, true
          key :type, :integer
          key :format, :int64
        end

        response 200 do
          key :description, 'Analysis response'
          schema do
            key :'$ref', :Analysis
          end
        end
      end
    end

    swagger_path "/analyses/{id}.xdsm" do
      operation :get do
        extend Api::V1::Concerns::Docs::ErrorResponses::AuthenticationError

        key :summary, 'Find analysis by id and return XDSM format'
        key :description, 'Returns the analysis specified with given id with XDSM format used by XDSMjs'
        key :tags, ['Analyses']
        security Token: []

        parameter do
          key :name, :id
          key :in, :path
          key :description, 'Analysis identifier'
          key :required, true
          key :type, :integer
          key :format, :int64
        end
        
        response 200 do
          key :description, 'Analysis response with XDSM format'
        end
      end
    end

    swagger_schema :Analysis do
      key :required, [:id, :name, :public, :created_at]
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :name do
        key :type, :string
      end
      property :public do
        key :type, :boolean
      end
      property :created_at do
        key :type, :string
        key :format, :"date-time"
      end
    end

  end

end