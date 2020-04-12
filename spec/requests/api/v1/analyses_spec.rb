require 'swagger_helper'

describe 'analyses', type: :request do

  path 'api/v1/analyses/{id}' do
    get 'Get an analysis' do
      tags 'Analyses'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'analysis found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            public: { type: :boolean },
            created_at: { type: :"date-time"}
          },
          required: [ 'id', 'name', 'public', 'created_at' ]

        let(:id) { Analysis.create(name: 'Foo').id }
        run_test!
      end

    end
  end

end
