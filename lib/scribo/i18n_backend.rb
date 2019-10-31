# frozen_string_literal: true

module Scribo
  class I18nBackend < I18n::Backend::Simple
    def initialize(*params)
      super
      @scribo_data = {}
      ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |_name, _started, _finished, _unique_id, _data|
        Rails.logger.info 'Resetting scribo translation cache'
        @scribo_data = {}
      end
    end

    def translate(locale, key, options = {})
      return unless options[:site]

      # I18n.backend = I18n::Backend::KeyValue.new(Rufus::Tokyo::Cabinet.new('*'))
      # * store#[](key)         - Used to get a value
      # * store#[]=(key, value) - Used to set a value
      # * store#keys            - Used to get all keys
      #
      total_key = key.start_with?('.') ? [locale, options[:scope]].join('.') + key : [locale, key].join('.')

      unless @scribo_data.key?(locale)
        locale_content = options[:site].contents.locale(locale).first
        unless locale_content
          @scribo_data[locale] = nil
          return
        end

        @scribo_data[locale] = Scribo::Utility.yaml_safe_parse(locale_content.data)
      end

      scribo_value = @scribo_data[locale].value_at_keypath(total_key)
      return unless scribo_value.present?

      if scribo_value.respond_to?(:gsub)
        options.each do |ikey, value|
          next unless value.is_a?(String)

          scribo_value = scribo_value.gsub("%{#{ikey}}", value) if value.is_a?(String)
        end
      end
      scribo_value
    end
  end
end
