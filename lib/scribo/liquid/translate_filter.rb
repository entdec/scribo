# frozen_string_literal: true

module TranslateFilter
  # Translate keys
  #
  # Usage:
  #
  # {{ key | translate: locale }}
  #
  # Examples:
  #
  # {{ '.next' | translate: 'en' }}
  #
  def translate(input, locale = 'en')
    I18n.t(input, locale: locale)
  end
end

Liquid::Template.register_filter(TranslateFilter)
