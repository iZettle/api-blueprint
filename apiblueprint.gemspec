$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api-blueprint/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api-blueprint"
  s.version     = ApiBlueprint::VERSION
  s.authors     = ["Damien Timewell"]
  s.email       = ["mail@damientimewell.com"]
  s.homepage    = "https://github.com/iZettle/api-blueprint"
  s.summary     = "Makes returning objects from api calls a breeze."
  s.description = "A faster, leaner, and simpler successor to ApiModel. Makes returning objects from api calls a breeze."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "dry-types", "~> 0.13"
  s.add_dependency "dry-struct", "~> 0.5"
  s.add_dependency "dry-initializer", "~> 2.4"
  s.add_dependency "dry-configurable", "~> 0.7"
  s.add_dependency "faraday", ">= 0.8"
  s.add_dependency "faraday_middleware", "~> 0.12.2"
  s.add_dependency "activemodel", [">= 5.1", "< 5.3"]
  s.add_dependency "activesupport", [">= 5.1", "< 5.3"]
  s.add_dependency "addressable", "~> 2.5"

  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "rspec", "~> 3.7"
  s.add_development_dependency "webmock", "~> 3.3"
  s.add_development_dependency "guard-rspec", "~> 4.7"
end
