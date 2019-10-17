module Api::V1::Concerns::Docs
  module DocsController 
    extend ActiveSupport::Concern
    include WhatsOpt::Version

    included do
      include Swagger::Blocks

      swagger_root do
        key :swagger, '2.0'
        info version: VERSION do
          key :title, 'WhatsOpt'
        end
        key :basePath, '/api/v1'
        key :schemes, ['https', 'http']
        key :consumes, ['application/json']
        key :produces, ['application/json']
        security_definition :Token, type: :apiKey do
          key :name, :Authorization
          key :in, :header
          key :description, 'Enter your token in the format **Token &lt;token&gt;**'
        end
      end

      SWAGGERED_CLASSES = [
        Api::V1::AnalysesController,
        Api::V1::MetaModelsController,
        Api::V1::Concerns::Docs::ErrorResponses::ErrorModel,
        Analysis,
        self
      ].freeze

      def show
        result = Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
        puts result
        render json: result
      end

    end
  end
end