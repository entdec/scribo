# frozen_string_literal: true

module TranslateFilter
  # Translate keys
  #
  # Usage:
  #
  # {{key | translate: locale}}
  # {{key | t: locale}}
  # {{key | t}}
  #
  # Examples:
  #
  # {{'.next' | translate: 'en'}}
  #
  def translate(input, locale = I18n.locale)
    content = @context.registers['content']
    scope = content ? content.translation_scope : nil
    I18n.t(input, locale: locale, scope: scope)
  end
  alias_method :t, :translate
end

Liquid::Template.register_filter(TranslateFilter)
