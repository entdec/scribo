# frozen_string_literal: true

module TranslateFilter
  # Translate text
  #
  # Example:
  #   <div class="summary">{{'.title' | t}}</div>
  #
  # provide optional locale to translate the text in, if you don't pass it it will use I18n.locale
  #
  def translate(input, locale = I18n.locale)
    content = @context.registers['content']
    scope = content ? content.translation_scope : nil
    I18n.t(input, locale: locale, scope: scope)
  end
  alias_method :t, :translate
end

Liquid::Template.register_filter(TranslateFilter)
