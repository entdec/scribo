$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scribo/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scribo"
  s.version     = Scribo::VERSION
  s.authors     = ["Tom de Grunt"]
  s.email       = ["tom@degrunt.nl"]
  s.homepage    = "https://gitlab.com/rocketcode/scribo"
  s.summary     = "A simple, embeddable CMS for Ruby on Rails"
  s.description = "Scribo is designed to work with your models and renders your content inside customer designed layouts."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "pg"
end
