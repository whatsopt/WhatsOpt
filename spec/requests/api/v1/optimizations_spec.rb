require 'swagger_helper'

describe 'optimization', type: :request do
  fixtures :all

  path '/api/v1/optimization/{:id}' do
    get 'Retrieve optimization result' do
      description "Get current optimizer status and x suggestion. <br/> \
      * PENDING  (-1): optimizer was not asked to compute x suggestion,</br> \
      * VALID    (0) : valid x suggestion,</br> \
      * INVALID  (1) : invalid x suggestion (at least one contraint is violated),</br> \
      * ERROR    (2) : runtime error,</br> \
      * SOLUTION (3) : known solution reached (not implemented),</br> \
      * RUNNING  (4) : computation in progress</br>" 
      tags 'Optimization'
      produces 'application/json'
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Optimization identifier"    

      response '200', "Retrieve current optimization result" do
        schema type: :object,
          description: "Optimization result",
          properties: {
            x_suggested: { 
              "$ref": '#components/schemas/RowVector'
            },
            status: { 
              type: :integer, 
              enum: [-1, 0, 1, 2, 3, 4]
            },
          },
          required: [ :x_suggested, :status ]

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { optimization(:optimization_ackley2d).id }
        run_test!
      end
    end
  end

  path '/api/v1/optimizations' do
    post 'Create an optimization context' do
      description "Initialize optimization context specifying design space and constraints"
      tags 'Optimization'
      consumes 'application/json'
      produces 'application/json'
      security [ Token: [] ]
      parameter name: :context, 
        in: :body, 
        type: :string, 
        schema: {
          description: "Optmization context: xlimits and optional constraints <br/>
          * xlimits: design space in matrix format (nxdim, 2). The ith row is [lower bound, upper bound] of the ith design variable. </br>
          * cstr_specs: constraint c specification either *c<bound*, *c>bound*, *c=bound* (default is *<0*)",
          type: :object,
          properties: {
            optimization: {
              type: :object,
              properties: {
                xlimits: {
                  "$ref": "#/components/schemas/XLimits" 
                },
                cstr_specs: {
                  type: :array,
                  items: {
                    "$ref": "#/components/schemas/ConstraintSpec"
                  }
                }
              },
              required: [:xlimits]
            }
          },
          required: [:optimization]
        }
      
      response '200', "x suggestion computation started" do
        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { optimization(:optimization_ackley2d).id }
        let(:context) { { optimization: { 
          xlimits: [[-32.768, 32.768], [-32.768, 32.768]]
        }}}
        run_test!
      end
        
    end
  end
  
  path '/api/v1/optimizations/{id}' do

    put 'Ask for next optimal x suggestion where f(x suggestion) is expected to be minimal' do
      description "Compute next x sample point suggestion regarding provided x, y which result of previous function f evaluations <br/> \
      and optional constraint functions g1, g2, ..., gn specified at optimization creation. </br> \
      Previous evaluations should result from an initial DOE execution followed by previous call evaluation on previous suggestions."
      tags 'Optimization'
      consumes 'application/json'
      produces 'application/json'
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Optimization identifier"
      parameter name: :context,
        in: :body,
        schema: {
          description: "x, y sampling points using matrix format (nsample, nxdim), (nsampling, nydim) <br/> \
          where <strong>nsampling</strong> is the number of sample points, <strong>nxdim</strong> the dimension of x and<br/> \
          <strong>nydim</strong> the dimension of y. <br/> \
          Each column of x corresponds to the various values of an *input variables* of the optimized function. <br/> \
          Each column of y corresponds to the various values of an *output variables* of the optimized function. <br/> \
          y sampling result from the concatenation of the objective function f scalar result (required) and optional <br /> \
          contraint functions g1, g2, etc evaluated at a given sampling point x. <br/> \
          For one sampling point x (x_1, x_2, ..., x_nxdim), x_\* values consist of input variables listed in *lexical order* <br/> \
          For one sampling result y (y_1, y_2, ..., y_nydim), x_\* values consist of output variables listed in *lexical order* <br/> \
          When a variable is multidimensional it should be expanded as variable's size scalar values<br/> \
          (example: z of shape (m, p, q) will expands in 'z[0]', 'z[1]', ..., 'z[m\*p\*q-1]', 'z[m\*p\*q]' scalar values).",
          type: :object,
          properties: { 
            optimization: {
              type: :object,
              properties: {
                x: { 
                  "$ref": "#/components/schemas/Matrix"
                },
                y: { 
                  "$ref": "#/components/schemas/Matrix"
                }
              }
            }
          }
        },
        required: true

      response '200', "x suggestion computation started" do

        let(:Authorization) { "Token FriendlyApiKey" }
        let(:id) { optimization(:optimization_ackley2d).id }
        let(:xydoe) { {optimization: { 
          x: [[0.1005624023, 0.1763338461],
              [0.843746558, 0.6787895599],
              [0.3861691997, 0.106018846]], 
          y: [[9.09955542], [6.38231049], [12.4677347]] }}}
        run_test!
      end

      # response '404', 'Analysis not found' do
      #   schema :$ref => "#/components/schemas/Error"

      #   let(:Authorization) { "Token FriendlyApiKey" }
      #   let(:id) { 'invalid' }
      #   run_test! 
      # end

      # response '401', 'Unauthorized access' do
      #   schema :$ref => "#/components/schemas/Error"

      #   let(:Authorization) { "Token FriendlyApiKey" } 
      #   let(:id) { analyses(:fast).id }
      #   run_test! 
      # end

    end
  end

  path '/api/v1/optimizations/{id}' do
    delete 'Destroy optimization context' do
      tags 'Optimization'
      security [ Token: [] ]
      parameter name: :id, in: :path, type: :string, description: "Optimization identifier"    

      response '200', "Optimization context successfully deleted" do
        let(:id) { optimization(:optimization_ackley2d).id }
        run_test!
      end
    end
  end

end
