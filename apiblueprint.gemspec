$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api-blueprint/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api-blueprint"
  s.version     = ApiBlueprint::VERSION
  s.authors     = ["Damien"]
  s.email       = ["mail@damientimewell.com"]
  s.homepage    = ""
  s.summary     = "Summary of ApiBlueprint."
  s.description = "Description of ApiBlueprint."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.5"
  s.add_dependency "dry-types"
  s.add_dependency "dry-struct"
  s.add_dependency "dry-initializer"
  s.add_dependency "dry-configurable"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "guard-rspec"
end
