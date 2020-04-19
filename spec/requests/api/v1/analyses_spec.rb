require 'swagger_helper'

describe 'analyses', type: :request do
  fixtures :all

  path '/api/v1/analyses' do
    
    get 'Get analyses' do
      tags 'Multi-Disciplinary Analyses'
      produces 'application/json'
      security [ Token: [] ]

      response '200', 'List analyses' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              public: { type: :boolean },
              created_at: { type: :string, format: :"date-time"}
            },
            required: [ 'id', 'name', 'public', 'created_at' ]
          }

        let(:Authorization) { "Token FriendlyApiKey" }
        run_test!
      end
    end
  end

  path '/api/v1/analyses/{id}.xdsm' do
    
    get 'Get XDSMjs format for given analysis' do
      tags 'Multi-Disciplinary Analyses'
      produces 'application/json'
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Analysis identifier"

      response '200', 'return XDSM structure' do
        schema "$ref": "#/components/schemas/Xdsm"
        
        let(:id) { analyses(:cicav).id }
        let(:Authorization) { "Token FriendlyApiKey" }
        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end

    end
  end

  # path '/api/v1/analyses.xdsm'

  #   post 'Get XDSMjs format of given analysis' do
  #     tags 'Multi-Disciplinary Analyses'
  #     consumes 'application/json'
  #     produces 'application/json'
  #     security [ Token: [] ]
  #     parameter name: :analysis_attributes, in: :body, 
  #       type: {
  #         "$ref": "#/components/schemas/AnalysisAttributes"
  #       }

  #     response '200', 'Get XDSMjs format for given analysis structure' do
  #       run_test!
  #     end
  #   end

  # end

end
