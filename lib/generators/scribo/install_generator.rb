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

    def add_content_to_tailwind_config
      inject_into_file "config/tailwind.config.js", before: "],\n  theme: {" do
        "  // Scribo content\n" +
          %w[/app/views/**/* /app/helpers/**/* /app/controllers/**/* /app/components/**/* /app/javascript/**/*.js /app/assets/**/scribo.css].map { |path| "    \"#{Scribo::Engine.root}#{path}\"" }.join(",\n") +
          ",\n  "
      end
    end

    def add_content_application_tailwind_css
      inject_into_file "app/assets/stylesheets/application.tailwind.css", before: "@tailwind base;" do
        "@import '#{Scribo::Engine.root}/app/assets/stylesheets/scribo/scribo.css';\n"
      end
    end
  end
end
