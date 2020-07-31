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

  s.add_dependency "dry-types", ">= 1.4"
  s.add_dependency "dry-struct"
  s.add_dependency "dry-initializer"
  s.add_dependency "dry-configurable"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "faraday-detailed_logger"
  s.add_dependency "activemodel"
  s.add_dependency "activesupport"
  s.add_dependency "addressable"

  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "guard-rspec"
end
