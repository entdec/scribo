# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo_name| "git@github.com:#{repo_name}" }
git_source(:entdec) { |repo_name| "git@github.com:entdec/#{repo_name}" }

# Declare your gem's dependencies in scribo.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

# bundle config --delete local.liquidum
# bundle config local.liquidum ../../components/liquidum

gem 'auxilium', '~> 3.0'
gem 'key_path', github: 'entdec/keypath-ruby.git', branch: 'master'

gem 'rubocop'
gem 'signum'

gem 'closure_tree'

group :test do
  gem 'pry-rails'
end
