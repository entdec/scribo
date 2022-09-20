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

# bundle config --delete local.liquor
# bundle config local.liquor ../../components/liquor

gem 'auxilium', '~> 3.0', entdec: 'auxilium'
gem 'key_path', github: 'tdegrunt/key_path.git', branch: 'master'
gem 'liquor', '~> 1', entdec: 'liquor'

gem 'rubocop'
gem 'signum'
group :test do
  gem 'pry-rails'
end
