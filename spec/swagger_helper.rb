# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'WhatsOpt API',
        version: 'v1',
        contact: {
          name: "API Support",
          email: "remi.lafage@onera.fr"
        },
        license: {
          "name": "Apache 2.0",
          "url": "https://www.apache.org/licenses/LICENSE-2.0.html"
        }
      },
      servers: [
        {url: "https://ether.onera.fr/whatsopt/api/v1", description: "External production server"},
        {url: "https://selene.onecert.fr/whatsopt/api/v1", description: "Internal production server"},
        {url: "http://rdri206h.onecert.fr/whatsopt/api/v1", description: "Internal staging server"},
        {url: "http://endymion:3000/api/v1", description: "Development server"},
        {url: "http://192.168.99.100:3000/api/v1", description: "Docker development server"},
      ],
      paths:{},
      components: {
        securitySchemes: {
          Token: {
            type: 'apiKey',
            in: 'header',
            name: "Authorization",
            description: 'Enter your API key with the format **Token &lt;API key&gt;**'
          }
        }
      },
      security: [{Token: []}],
      externalDocs: {
        description: "Find out more on WhatsOpt",
        url: "http://github.com/OneraHub/WhatsOpt",
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
