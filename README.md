# ApiBlueprint

ApiBlueprint is a simple wrapper designed to be used in a Rails app for running http requests through Faraday and generating strongly-typed models from the JSON responses.

## Example use

The examples below use the [open notify astros](http://api.open-notify.org/astros.json) api endpoint to list the astronauts who are current in space and which craft they are on.

### Blueprints in models

Using ApiBlueprint::Model, you can define model classes with [dry-types attributes](http://dry-rb.org/gems/dry-types/) and define blueprints which describe how an api call will be made.

```ruby
# app/models/person.rb
class Person < ApiBlueprint::Model
  attribute :name, Types::String
  attribute :craft, Types::String
end

# app/models/astronauts_in_space.rb
class AstronautsInSpace < ApiBlueprint::Model
  attribute :number, Types::Integer
  attribute :people, Types::Array.of(Types.Constructor(Person))

  def self.fetch
    blueprint :get, "http://api.open-notify.org/astros.json"
  end
end
```

### Running blueprints

Blueprints can be run from controllers using an instance of `ApiBlueprint::Runner`. You can use that runner instance to store session based information such as Authorization headers and such which need to be passed into requests.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def api
    ApiBlueprint::Runner.new headers: { Authorization: "something" }
  end
end

# app/controllers/astronauts_controller.rb
class AstronautsController < ApplicationController
  def index
    @astronauts = api.run AstronautsInSpace.fetch
  end
end
```

The result of using `api.run` on a blueprint is as you'd expect, nice model instances with the attributes set:

```erb
<!-- app/views/astronauts/index.html.erb -->
<h1>There are <%= @astronauts.number %> astronauts in space currently:</h1>

<ul>
  <% @astronauts.each do |astronaut| %>
    <li><%= astronaut.name %> is on <%= astronaut.craft %></li>
  <% end %>
</ul>
```

## Collections

Sometimes you might want a model which requires multiple api calls and collects the results onto different attributes. You can use an `ApiBlueprint::Model.collection` for this.

```ruby
class Vehicles < ApiBlueprint::Model
  attribute :car, Types.Constructor(Car)
  attribute :bus, Types.Constructor(Bus)

  def self.fetch_all(color)
    collection \
      car: Car.all(color),
      bus: Bus.all(color)
  end
end

# Example use
red_vehicles = api.run Vehicles.fetch_all("red")
red_vehicles.cars # [<Car>, <Car>, ...]
red_vehicles.busses # [<Bus>, <Bus>, ...]
```

## Request registry

If you use the same api request in multiple controllers, it can be cumbersome to remember to set the cache options and pass all required params to api calls. ApiBlueprint includes a registry, which can be used as a container to store blueprints along with cache options and make it quicker and simpler to re-use in controllers.

You can add to the registry when initialing the api runner, or later.

```ruby
# Add `astronauts_in_space` to the registry when initializing the runner:
api = ApiBlueprint::Runner.new registry: {
  astronauts_in_space: { blueprint: -> { AstronautsInSpace.fetch }, cache: { ttl: 10.minutes } }
}

# Add `vehicles` to the existing registry:
api.register :vehicles, -> { Vehicles.fetch_all }, ttl: 60.minutes
```

Once a blueprint is registered in the registry, you can invoke it via the key name on the runner:

```ruby
api.astronauts_in_space # the same as running api.run AstronautsInSpace.fetch, ttl: 10.minutes
api.vehicles # the same as running api.run Vehicles.fetch_all, ttl: 60.minutes
```

## Model Configuration

Using a `configure` block on models, you can define a default url (host), a [parser](#configparser), a [builder](#configbuilder) and can define a list of [replacements](#configreplacements):

```ruby
class AstronautsInSpace < ApiBlueprint::Model
  configure do |config|
    config.host = "http://api.open-notify.org"
    config.parser = CustomResponseParser.new
    config.builder = CustomObjectBuilder.new
    config.replacements = {}
  end
end
```

### Config.builder

When running a blueprint, after the response is returned and parsed, the result is passed to a builder, which is responsible for initializing objects from the response. The default [ApiBlueprint::Builder](https://github.com/iZettle/api-blueprint/blob/master/lib/api-blueprint/builder.rb)
 will pass the attributes from the response into the initializer for the class the blueprint was defined in.

If you want to change the behavior of the builder, or have a complex response which needs manipulation before it should be passed to the initializer, you can define a custom builder. Custom builders must inherit from the default builder, and can override any combination of the core methods which are used to build responses; `build`, `prepare_item`, and `build_item`. Refer to the [default builder](https://github.com/iZettle/api-blueprint/blob/master/lib/api-blueprint/builder.rb) to see what those methods do.

### Config.parser

The parser is responsible for taking the raw response body string and generating a useful object from it, which can be passed into the builder to generate instances of the model. The [default parser](https://github.com/iZettle/api-blueprint/blob/master/lib/api-blueprint/parser.rb) is used to parse json strings and return a hash.

If you need a custom parser (for example, an XML parser), you must define a class which inherits from `ApiBlueprint::Parser`, and overrides the `#parse` method.

### Config.replacements

Replacements can be used to handle poorly named keys in api responses, or to re-word things without the need to creating a custom builder. For example, if the api by default returned a key called `numberOfAstronautsInSpace` and you wanted this to assign the `number` attribute on the model, you could use a replacement to handle that:

```ruby
config.replacements = {
  numberOfAstronautsInSpace: :number
}
```

## Validation

You can use [active model validations](http://guides.rubyonrails.org/active_record_validations.html) on models to validate body payloads. This is useful to pre-check user input before sending API requests. It is disabled by default, but to enable, you just need to set `validate: true` on your blueprint definitions:

```ruby
class Astronaut < ApiBlueprint::Model
  attribute :name, Types::String
  validates :name, presence: true

  def self.send_to_space(name)
    blueprint :post, "/space", body: { name: name }, validate: true
  end
end

Astronaut.send_to_space(nil) # => <ActiveModel::Errors ...>
```

Behind the scenes, ApiBlueprint uses the body hash to initialize a new instance of your model, and then runs validations. If there are any errors, the API request is not run and the errors object is returned.

## Error handling

If an API response includes an `errors` object, ApiBlueprint uses it to assign `ActiveModel::Errors` instances on the class which is built. This way, validation errors which come an the API behave exactly the same as validation errors set locally through validations on the model.

Certain response statuses will also cause ApiBlueprint to behave in different ways:

| HTTP Status range | Behavior |
| ----------------- | -------- |
| 200 - 400 | Objects are built normally, no errors raised |
| 401 | raises `ApiBlueprint::UnauthenticatedError` |
| 404 | raises `ApiBlueprint::NotFoundError` |
| 402 - 499 | raises `ApiBlueprint::ClientError` |
| 500 - 599 | raises `ApiBlueprint::ServerError` |

## Access to response headers and status codes

By default, ApiBlueprint tries to set `response_headers` and `response_status` on the model which is created from an API response. `ApiBlueprint::Model` also has a convenience method `api_request_success?` which can be used to easily assert whether a response was in the 200-399 range. This makes it simple to render different responses in controllers. For example:

```ruby
# app/controllers/astronauts_controller.rb
class AstronautsController < ApplicationController
  def index
    @astronauts = api.run AstronautsInSpace.fetch
    if @astronauts.api_request_success?
      render json: @astronauts
    else
      render json: @astronauts.errors, status: :bad_request
    end
  end
end
```

## Blueprint options

When defining a blueprint in a model, you can pass it a number of options to set request headers, params, body, or to run code after an instance of the model has been initialized. Here's some examples:

```ruby
# Most basic usage
blueprint :get, "/endpoint"

# Different http methods are supported (:get, :post, :put, :delete, :head, :patch, :options)
blueprint :put, "/endpoint"

# Request headers, body, or params can be passed along
blueprint :post, "/endpoint", {
  headers: { "Content-Type": "application/json" },
  params: { hello: "world" },
  body: { something: "in the body" }
}

# If you need to modify the instance which will be returned, or run subsequent requests using
# the runner, you can do so in a block. Note, this is the only place the runner will be available
# when running the blueprint.
blueprint :get, "/endpoint" do |runner, result|
  result.tap do |astronaut|
    astronaut.number = 23 # override something
    astronaut.more_info = runner.run SomeOtherModel.fetch # run another request
  end
end
```

## Response logging

Response logging can be enabled on a per-blueprint level, or by setting `config.log_responses = true` on an `ApiBlueprint::Model`:

```ruby
class AstronautsInSpace < ApiBlueprint::Model
  configure do |config|
    # enable logging for all blueprints
    config.log_responses = true
  end

  def self.fetch
    # enable logging for just one blueprint
    blueprint :get, "http://api.open-notify.org/astros.json", log_responses: true
  end
end
```

## Caching

ApiBlueprint includes the ability to cache responses and avoid numerous api calls to endpoints, but does not implement a caching mechanism itself. Instead it exposes a skeleton cache class which you can override with your own caching mechanism. See the [Rails cache example](https://github.com/iZettle/api-blueprint/blob/master/examples/cache.rb) for an example implementation using `Rails.cache.write`, `Rails.cache.read`, etc.

Caching is enabled on the runner level. In this case, using the Rails session id to make the cache unique to each user:

```ruby
ApiBlueprint::Runner.new({
  cache: BlueprintCache.new(key: session.id)
})
```

The `ApiBlueprint::Cache` class has a method to generate unique keys for the cache items by creating a checksum of the request headers and url. It doesn't include the body of the request in this checksum by default, and if you want to exclude more headers, you can do so using the `ignored_headers` setting on the Cache class. For example, to not include "X-Real-IP" and "X-Request-Id" headers, which would otherwise render the cache useless:

```ruby
 ApiBlueprint::Cache.configure do |config|
   # Using .concat here because the default is [:body] and you probably want to keep that
   config.ignored_headers.concat ["X-Real-IP", "X-Request-Id"]
 end
```

## A note on Dry::Struct immutability

Models you create use `Dry::Struct` to handle initialization and assignment. `Dry::Struct` is designed with immutability in mind, so if you need to mutate the objects you have, there are two possibilities; explicitly define an `attr_writer` for the attributes which you want to mutate, or do things the "Dry::Struct way" and use the current instance to initialize a new instance:

```ruby
astros = AstronautsInSpace.new number: 5, foo: "bar"
astros.number # => 5
astros.number = 10 # NoMethodError: undefined method `number=' for #<AstronautsInSpace number=5 foo="bar">
new_astros = astros.new number: 10
new_astros # #<AstronautsInSpace number=10 foo="bar">
```
