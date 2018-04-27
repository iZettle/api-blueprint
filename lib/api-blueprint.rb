require 'dry-types'
require 'dry-struct'
require 'dry-initializer'
require 'faraday'
require 'faraday_middleware'
require 'active_model'
require 'active_support/core_ext/hash'
require 'addressable'

require 'api-blueprint/response_middleware'
require 'api-blueprint/cache'
require 'api-blueprint/types'
require 'api-blueprint/url'
require 'api-blueprint/parser'
require 'api-blueprint/builder'
require 'api-blueprint/model'
require 'api-blueprint/blueprint'
require 'api-blueprint/runner'
require 'api-blueprint/collection'

module ApiBlueprint
  class ResponseError < StandardError
    attr_reader :status, :headers, :body
    def initialize(env)
      @status = env.status
      @headers = env.response_headers.symbolize_keys
      @body = env.body
    end
  end

  class DefinitionError < StandardError; end
  class BuilderError < StandardError; end
  class ServerError < ResponseError; end
  class UnauthenticatedError < ResponseError; end
  class ClientError < ResponseError; end
  class NotFoundError < ResponseError; end
end
