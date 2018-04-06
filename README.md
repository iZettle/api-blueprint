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
