# require 'swagger_helper'

# describe 'meta_models', type: :request do
#   fixtures :all

#   path '/api/v1/meta_models/{id}' do

#     put 'Predict using the metamodel' do
#       description "Compute y responses at given x points."
#       tags 'MetaModels'
#       consumes 'application/json'
#       produces 'application/json'
#       security [ Token: [] ]
#       parameter name: :id, in: :path, type: :string, description: "MetaModel identifier"
#       parameter name: :x,
#         description: "TEST",
#         in: :body,
#         schema: {
#           type: :object,
#           properties: { 
#             meta_model: {
#               type: :object,
#               properties: {
#                 description: "x points where to predict using matrix format (nx, nxdim) <br/> \
#                 where <strong>nx</strong> is the number of points and <strong>nxdim</strong> the dimension of x<br/> \
#                 Each columns corresponds to the various values of an input variables of the metamodel. <br/> \
#                 For one point x (x_1, x_2, ..., x_nxdim), x_\* values consist of input variables listed in *lexical order* <br/> \
#                 When a variable is multidimensional it should be expanded as variable's size scalar values<br/> \
#                 (example: z of shape (m, p, q) will expands in 'z[0]', 'z[1]', ..., 'z[m\*p\*q-1]', 'z[m\*p\*q]' scalar values).",
#                 x: { 
#                   "$ref": "#/components/schemas/Matrix"
#                 }
#               }
#             }
#           }
#         },
#         required: true

#       response '200', "y predictions at x points in matrix format (nx, nydim)" do
#         schema type: :object,
#           properties: {
#             y: {
#               "$ref": "#/components/schemas/Matrix"
#             } 
#           }

#         let(:Authorization) { "Token FriendlyApiKey" }
#         let(:id) { meta_models(:cicav_metamodel).id }
#         let(:x) {{meta_model: {values:[[3, 5, 7], [6, 10, 1]]}}}
#         run_test!
#       end

#       # response '404', 'Analysis not found' do
#       #   schema :$ref => "#/components/schemas/Error"

#       #   let(:Authorization) { "Token FriendlyApiKey" }
#       #   let(:id) { 'invalid' }
#       #   run_test! 
#       # end

#       # response '401', 'Unauthorized access' do
#       #   schema :$ref => "#/components/schemas/Error"

#       #   let(:Authorization) { "Token FriendlyApiKey" } 
#       #   let(:id) { analyses(:fast).id }
#       #   run_test! 
#       # end

#     end
#   end

# end
