# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.3",
      info: {
        title: "WhatsOpt API",
        version: "v1",
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
        { url: "https://ether.onera.fr/whatsopt", description: "External production server" },
        { url: "https://selene.onera.net/whatsopt", description: "Internal production server" },
        { url: "http://erebe.onera.net/whatsopt", description: "Restricted server" },
        { url: "https://selene.onera.net/whatsopt-dev", description: "Internal staging server" },
        { url: "http://erebe.onera.net:3000", description: "Development server" },
      ],
      paths: {},
      components: {
        schemas: {
          AnalysisInfo: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: :"date-time" },
              owner_email: { type: :string, format: :"email" },
              notes: { type: :string }
            },
          },
          AnalysisAttributes: {
            type: :object,
            properties: {
              name: { type: :string },
              disciplines_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    variables_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          name: { type: :string },
                          io_mode: {
                            type: :string,
                            enum: ["in", "out"]
                          }
                        }
                      }
                    },
                    sub_analysis_attributes: {
                      "$ref": "#/components/schemas/AnalysisAttributes"
                    }
                  }
                }
              }
            }
          },
          ConstraintSpec: {
            type: :object,
            properties: {
              type: {
                type: :string,
                enum: ["<", ">", "="],
                default: "<"
              },
              bound: {
                type: :number,
                format: :double,
                default: 0.0
              }
            }
          },
          Error: {
            type: :object,
            properties: {
              message: { type: :string }
            }
          },
          Interval: {
            type: :array,
            items: {
              type: :number,
              format: :double
            },
            minItems: 2,
            maxItems: 2
          },
          Matrix: {
            description: "list of row vectors",
            type: :array,
            items: {
              "$ref": "#components/schemas/RowVector"
            },
            minItems: 1
          },
          RowVector: {
            type: :array,
            items: {
              type: :number,
              format: :double
            },
            minItems: 1
          },
          XLimits: {
            description: "design space (nxdim intervals)",
            type: :array,
            items: {
              "$ref": "#components/schemas/Interval"
            },
            minItems: 1
          },
          Xdsm: {
            type: :object,
            additionalProperties: {
              type: :object,
              properties: {
                nodes: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      name: { type: :string },
                      type: { type: :string }
                    }
                  }
                },
                edges: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      from: { type: :string },
                      to: { type: :string },
                      name: { type: :string }
                    }
                  }
                }
              }
            }
          }
        },
        securitySchemes: {
          Token: {
            type: "apiKey",
            in: "header",
            name: "Authorization",
            description: "Enter your API key with the format **Token &lt;API key&gt;**"
          }
        },
      },
      security: [{ Token: [] }],
      tags: [
        { name: "Multi-Disciplinary Analyses", description: "Operations for using analyses created in WhatsOpt" }
      ],
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
