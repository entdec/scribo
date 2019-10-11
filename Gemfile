# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:entdec) { |repo_name| "git@code.entropydecelerator.com:#{repo_name}.git" }

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

gem 'liquor', entdec: 'components/liquor', tag: '0.5.14'
gem 'key_path', git: 'git@code.entropydecelerator.com:tdegrunt/key_path.git', branch: 'master'

group :test do
  gem 'pry-rails'
end
