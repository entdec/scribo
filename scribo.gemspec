# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'scribo/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'scribo'
  s.version     = Scribo::VERSION
  s.authors     = ['Tom de Grunt']
  s.email       = ['tom@degrunt.nl']
  s.homepage    = 'https://gitlab.com/tdegrunt/scribo'
  s.summary     = 'An easy to use, embeddable CMS for Ruby on Rails'
  s.description = 'Scribo is designed to work with your models and renders your content inside customer designed layouts.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'awesome_nested_set', '~> 3.1'
  s.add_dependency 'liquor', '~> 0.1'
  s.add_dependency 'pg'
  s.add_dependency 'rails', '~> 5'
  s.add_dependency 'rubyzip', '~> 1.1'
  s.add_dependency 'simple_form', '> 3'
  s.add_dependency 'slim-rails', '~> 3.2'
  s.add_dependency 'state_machines-activerecord', '~> 0.5'
  s.add_dependency 'easy_translate'

  s.add_development_dependency 'minitest', '~> 5.11'
  s.add_development_dependency 'minitest-reporters', '~> 1.1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rails', '~> 0.3'
  s.add_development_dependency 'rubocop', '~> 0.60'
end
