# frozen_string_literal: true

require 'i18n/core_ext/hash'

module Scribo
  begin
    require 'oj'
    class JSON
      class << self
        def encode(value)
          Oj::Rails.encode(value)
        end

        def decode(value)
          Oj.load(value)
        end
      end
    end
  rescue LoadError
    require 'active_support/json'
    JSON = ActiveSupport::JSON
  end

  class I18nStore
    def initialize; end

    def keys
      return [] unless content

      result = []
      locales.each do |locale|
        result += flat_hash(YAML.safe_load(locale.data)).keys
      end
      result
    end

    def [](key)
      return unless content

      result = {}
      locales.each do |locale|
        hash = flat_hash(YAML.safe_load(locale.data)).transform_values { |v| JSON.encode(v) }
        result.merge! hash
      end
      result[key]
    end

    def []=(key, value)
      # NOOP
    end

    def with(content)
      with_custom_backend do
        self.content = some_content
        yield
        self.content = nil
      end
    end

    def content
      Thread.current[:scribo_i18n_store_content]
    end

    def content=(content)
      Thread.current[:scribo_i18n_store_content] = content
    end

    private

    def with_custom_backend
      Thread.current[:scribo_i18n_store_old_backend] = I18n.backend
      I18n.backend = I18n::Backend::Chain.new(custom_i18n_backend, I18n.backend)

      yield
``
      I18n.backend = Thread.current[:scribo_i18n_store_old_backend]
    end

    def locales
      content.site.contents.locales
    end

    def flat_hash(hash)
      hash.reduce({}) do |a, (k, v)|
        tmp = v.is_a?(Hash) ? flat_hash(v).map { |k2, v2| ["#{k}.#{k2}", v2] }.to_h : { k => v }
        a.merge(tmp)
      end
    end

    # Yield our own custom backend
    def custom_i18n_backend
      return @custom_i18n_backend if @custom_i18n_backend

      @custom_i18n_backend = I18n::Backend::KeyValue.new(Scribo.i18n_store)
      @custom_i18n_backend.class.send(:include, I18n::Backend::Cascade)

      @custom_i18n_backend
    end
  end
end
