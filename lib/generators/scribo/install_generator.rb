module Scribo
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_initializer_file
      template "config/initializers/scribo.rb"
    end

    def add_route
      return if Rails.application.routes.routes.detect { |route| route.app.app == Scribo::Engine }
      route %(mount Scribo::Engine => "/scribo")
    end

    def copy_migrations
      rake "scribo:install:migrations"
    end

    def tailwindcss_config
      rake "scribo:tailwindcss:config"
    end
  end
end
