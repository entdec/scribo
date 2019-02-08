# frozen_string_literal: true

require 'i18n'

module Scribo
  class Engine < ::Rails::Engine
    isolate_namespace Scribo

    initializer 'scribo.config' do |_app|
      # FIXME: How to make this work with Scribo and Nuntius
      I18n.backend = I18n::Backend::Chain.new(Scribo::BucketI18nBackend.new, I18n.backend)
      I18n.backend.class.send(:include, I18n::Backend::Cascade)
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
