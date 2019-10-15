module Api::V1::Concerns::Docs::AnalysesController
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks

    swagger_path "/analyses" do
      operation :get do
        key :summary, 'List analyses'
        key :description, 'Returns the list of analyses the user have read access on'
        key :tags, [
          'analyses'
        ]
        security Token: []

        response 200 do
          key :description, 'analyses response'
          schema type: :array do
            items do
              key :'$ref', :Analysis
            end
          end
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