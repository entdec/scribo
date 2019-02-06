module Scribo
  class BucketI18nBackend < I18n::Backend::Simple

    def translate(locale, key, options = {})
      return unless options[:bucket]

      # I18n.backend = I18n::Backend::KeyValue.new(Rufus::Tokyo::Cabinet.new('*'))
      # * store#[](key)         - Used to get a value
      # * store#[]=(key, value) - Used to set a value
      # * store#keys            - Used to get all keys
      #
      scribo_value = options[:bucket].translations.value_at_keypath([I18n.locale.to_s + key].join('.')) || super
      return unless scribo_value.present?

      options.each do |key, value|
        scribo_value = scribo_value.gsub("%{#{key}}", value) if scribo_value.respond_to?(:gsub) && value.is_a?(String)
      end
      scribo_value
    end
  end
end
