# frozen_string_literal: true

require 'i18n'
require 'slim'
require 'tailwindcss-rails'
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

module Scribo
  class Engine < ::Rails::Engine
    isolate_namespace Scribo

    initializer 'scribo.assets' do |app|
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.paths << root.join("app/components")
      app.config.assets.paths << Scribo::Engine.root.join("vendor/javascript")
      app.config.assets.precompile += %w[scribo_manifest]
    end

    initializer 'scribo.importmap', before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
      app.config.importmap.cache_sweepers << root.join("app/components")
      app.config.importmap.cache_sweepers << Scribo::Engine.root.join("vendor/javascript")
    end

    initializer 'scribo.config' do |_app|
      path = File.expand_path(File.join(File.dirname(__FILE__), '.', 'liquid', '{tags,filters}', '*.rb'))
      Dir.glob(path).each do |c|
        require_dependency(c)
      end
    end
  end
end
