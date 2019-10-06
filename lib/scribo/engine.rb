# frozen_string_literal: true

require 'i18n'

module Scribo
  class Engine < ::Rails::Engine
    isolate_namespace Scribo

    initializer 'scribo.config' do |_app|
      I18n.backend = I18n::Backend::Chain.new(Scribo::I18nBackend.new, I18n.backend)
      I18n.backend.class.send(:include, I18n::Backend::Cascade)

      path = File.expand_path(File.join(File.dirname(__FILE__), '.', 'liquid', '{tags,filters}', '*.rb'))
      Dir.glob(path).each do |c|
        require_dependency(c)
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
