module Api::V1::Concerns::Docs::MetaModelsController
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks

    swagger_path "/meta_models/{id}" do
      operation :put do
        extend Api::V1::Concerns::Docs::ErrorResponses::AuthenticationError
        extend Api::V1::Concerns::Docs::ErrorResponses::BadRequest

        key :summary, 'Predict at given points with metamodel '
        key :description, 'Returns the analysis specified with given id'
        key :tags, ['MetaModel']
        security Token: []

        parameter do
          key :name, :id
          key :in, :path
          key :description, 'MetaModel identifier'
          key :required, true
          key :type, :integer
          key :format, :int64
        end

        parameter do
          key :name, :format
          key :in, :body
          key :description, 'Points format'
          key :required, true
          schema do
            key :type, :string
            key :enum, ["matrix"]
          end
        end

        parameter type: :array do
          items do
            key :type, :array
            items do
              key :type, :number
              key :format, :double
            end
          end
          key :in, :body
          key :name, :values
          key :description, "Points where to predict in matrix format (nx, nxdim) <br/> \
            where <strong>nx</strong> is the number of points and <strong>nxdim</strong> the number of scalar inputs <br/> \
            For one point x (x_1, x_2, ..., x_nxdim), coordinates consist of variable values listed in lexical order <br/> \
            When a variable is multidimensional it should be expanded as variable's size scalar variables with indexed names <br/> \
            (example: z of shape (m, p, q) corresponds to 'z[0]', 'z[1]', ..., 'z[m*p*q]' scalar variables)."
          key :required, true
        end

        response 200 do
          key :description, "MetaModel response as a matrix (nx, nydim) where <strong>nx</strong> is the number of input points <br/> \
            and <strong>nydim</strong> the number of scalar outputs. <br/> \
            Scalar outputs follow the same convention as input values related to output variables names.<br/>"
          schema type: :array do
            items type: :array do
              items do
                key :type, :number
                key :format, :float 
              end
            end
          end
        end

      end
    end
  end
end
