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

## Model Configuration

Using a `configure` block on models, you can define a default url (host), a [parser](#configparsers), a [builder](#configbuilder) and can define a list of [replacements](#configreplacements):

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

## A note on Dry::Struct immutability

Models you create use `Dry::Struct` to handle initialization and assignment. `Dry::Struct` is designed with immutability in mind, so if you need to mutate the objects you have, there are two possibilities; explicitly define an `attr_writer` for the attributes which you want to mutate, or do things the "Dry::Struct way" and use the current instance to initialize a new instance:

```ruby
astros = AstronautsInSpace.new number: 5, foo: "bar"
astros.number # => 5
astros.number = 10 # NoMethodError: undefined method `number=' for #<AstronautsInSpace number=5 foo="bar">
new_astros = astros.new number: 10
new_astros # #<AstronautsInSpace number=10 foo="bar">
```
