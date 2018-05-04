module ApiBlueprint
  class ResponseMiddleware < Faraday::Response::Middleware

    def on_complete(env)
      case env[:status]
      when 401
        raise ApiBlueprint::UnauthenticatedError.new(env)
      when 404
        raise ApiBlueprint::NotFoundError.new(env)
      when 402..499
        raise ApiBlueprint::ClientError.new(env)
      when 500...599
        raise ApiBlueprint::ServerError.new(env)
      end
    end

  end
end
