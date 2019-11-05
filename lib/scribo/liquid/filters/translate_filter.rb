# frozen_string_literal: true

module TranslateFilter
  # Translate text
  #
  # Example:
  #   <div class="summary">{{'.title' | t}}</div>
  #
  # provide optional locale to translate the text in, if you don't pass it it will use I18n.locale
  #
  #   <div class="summary">{{'.title' | t: locale: 'nl'}}</div>
  #
  # you can provide additional arguments to be used for interpolation:
  #
  #   <div class="summary">{{'.title' | t: gender: 'm', locale: 'nl'}}</div>
  #

  def translate(input, options = {})
    scope = Liquor.config.translation_scope(@context).split('.')
    locale = options.delete('locale')

    begin
      result = I18n.translate(input, options, locale: locale, scope: scope.join('.'), site: @context.registers['content']&.site)
      return result if !(result.nil? || result.include?('translation missing:'))
      scope.pop
    end while !scope.empty?
  end
  alias_method :t, :translate
end

Liquid::Template.register_filter(TranslateFilter)
