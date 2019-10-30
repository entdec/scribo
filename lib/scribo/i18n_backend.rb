# frozen_string_literal: true

module Scribo
  class I18nBackend < I18n::Backend::Simple
    def translate(locale, key, options = {})
      return unless options[:site]

      # I18n.backend = I18n::Backend::KeyValue.new(Rufus::Tokyo::Cabinet.new('*'))
      # * store#[](key)         - Used to get a value
      # * store#[]=(key, value) - Used to set a value
      # * store#keys            - Used to get all keys
      #
      total_key = key.start_with?('.') ? [locale, options[:scope]].join('.') + key : [locale, key].join('.')

      locale_content = options[:site].contents.locale(locale).first
      return unless locale_content

      scribo_value = Scribo::Utility.yaml_safe_parse(locale_content.data).value_at_keypath(total_key)
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
