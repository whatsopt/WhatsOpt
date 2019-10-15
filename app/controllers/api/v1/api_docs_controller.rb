module Api::V1
  class ApiDocsController < Api::ApiController
    include Api::V1::Concerns::Docs::DocsController
  end
end