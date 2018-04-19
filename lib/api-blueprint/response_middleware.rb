module ApiBlueprint
  class ResponseMiddleware < Faraday::Response::Middleware

    def on_complete(env)
      case env[:status]
      when 401
        raise ApiBlueprint::UnauthenticatedError, response_values(env)
      when 402..499
        raise ApiBlueprint::ClientError, response_values(env)
      when 500...599
        raise ApiBlueprint::ServerError, response_values(env)
      end
    end

    def response_values(env)
      { status: env.status, headers: env.response_headers, body: env.body }
    end

  end
end
