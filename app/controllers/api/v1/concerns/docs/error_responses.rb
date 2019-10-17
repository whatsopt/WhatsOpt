module Api::V1::Concerns::Docs::ErrorResponses

  class ErrorModel 
    include Swagger::Blocks
  
    swagger_schema :ErrorModel do
      key :required, :message
      property :message do
        key :type, :string
      end
    end
  end

  module AuthenticationError

    def self.extended(base)
      base.response 401 do
        key :description, 'Not Authorized'
      end
    end

  end

  module NotFoundError

    def self.extended(base)
      base.response 404 do
        key :description, 'Not found'
      end
    end
    
  end

  module BadRequest

    def self.extended(base)
      base.response 400 do
        key :description, 'Bad Request'
        schema do
          key :'$ref', :ErrorModel
        end
      end
    end

  end

end