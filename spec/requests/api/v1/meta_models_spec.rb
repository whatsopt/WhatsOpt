# frozen_string_literal: true

require "swagger_helper"

describe "meta_model", type: :request do
  fixtures :all

  path "/api/v1/meta_models" do
    get "Get meta-models" do
      tags "Meta-Modeling"
      produces "application/json"
      security [ Token: [] ]

      response "200", "List meta-models" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              reference_analysis: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  created_at: { type: :string, format: :"date-time" },
                },
              },
            },
            required: [ "id", "reference_analysis" ]
          }

        let(:Authorization) { "Token FriendlyApiKey" }
        run_test!
      end
    end
  end

  path "/api/v1/meta_models/{id}" do
    get "Get meta-model details" do
      tags "Meta-Modeling"
      produces "application/json"
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Meta-model identifier"

      response "200", "return meta-model information" do
        schema type: :object,
        properties: {
          id: { type: :integer },
          reference_analysis: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: :"date-time" },
              owner_email: { type: :string, format: :email },
              notes: { type: :string }
            },
          },
          xlabels: { type: :array, items: { type: :string } },
          ylabels: { type: :array, items: { type: :string } },
        }

        let(:id) { meta_models(:cicav_metamodel).id }
        let(:Authorization) { "Token FriendlyApiKey" }
        after do |example|
          example.metadata[:response][:examples] = { "application/json" => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end

    put "Predict using the meta-model" do
      description "Compute y responses at given x points"
      tags "Meta-Modeling"
      consumes "application/json"
      produces "application/json"
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "MetaModel identifier"
      parameter name: :xpoints,
        in: :body,
        schema: {
          description: "x points where to predict using matrix format (nsampling, nxdim) <br/> \
          where <strong>nsampling</strong> is the number of points and <strong>nxdim</strong> the dimension of x<br/> \
          Each column corresponds to the various values of an input variables of the metamodel. <br/> \
          For one sampling point x (x_1, x_2, ..., x_nxdim), x_\* values consist of input variables listed in *lexical order* <br/> \
          When a variable is multidimensional it should be expanded as variable's size scalar values<br/> \
          (example: z of shape (m, p, q) will expands in 'z[0]', 'z[1]', ..., 'z[m\*p\*q-1]', 'z[m\*p\*q]' scalar values).",
          type: :object,
          properties: {
            meta_model: {
              type: :object,
              properties: {
                x: {
                  "$ref": "#/components/schemas/Matrix"
                }
              }
            }
          }
        },
        required: true

      response "200", "y predictions at x points in matrix format (nsample, nydim)" do
        schema type: :object,
          properties: {
            y: {
              "$ref": "#/components/schemas/Matrix"
            }
          }

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { meta_models(:cicav_metamodel).id }
        let(:xpoints) { { meta_model: { x: [[3, 5, 7], [6, 10, 1]] } } }
        run_test!
      end

      response "404", "MetaModel not found" do
        schema :$ref => "#/components/schemas/Error"

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { "invalid" }
        let(:xpoints) { { meta_model: { x: [[3, 5, 7], [6, 10, 1]] } } }
        run_test!
      end

      # for now anybody has access to any metamodel
      # response '401', 'Unauthorized access' do
      #   schema :$ref => "#/components/schemas/Error"

      #   let(:Authorization) { "Token FriendlyApiKey3" }
      #   let(:id) { meta_models(:cicav_metamodel2).id }
      #   let(:xpoints) { {meta_model: { x: [[3, 5, 7], [6, 10, 1]] }} }
      #   run_test!
      # end
    end
  end
end
