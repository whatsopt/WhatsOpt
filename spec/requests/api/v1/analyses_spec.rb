require 'swagger_helper'

describe 'analyses', type: :request, document: false do
  fixtures :all

  path '/api/v1/analyses/{id}' do
    get 'Get analysis information' do
      tags 'Multi-Disciplinary Analyses'
      produces 'application/json'
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Analysis identifier"

      response '200', 'Analysis found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            public: { type: :boolean },
            created_at: { type: :string, format: :"date-time"}
          },
          required: [ 'id', 'name', 'public', 'created_at' ]

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { analyses(:cicav).id }
        run_test!
      end

      response '404', 'Analysis not found' do
        schema :$ref => "#/components/schemas/Error"

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { 'invalid' }
        run_test! 
      end

      response '401', 'Unauthorized access' do
        schema :$ref => "#/components/schemas/Error"

        let(:Authorization) { "Token FriendlyApiKey" } 
        let(:id) { analyses(:fast).id }
        run_test! 
      end

    end
  end

end
