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
    content = @context.registers['content']
    return unless content

    result = nil

    Scribo.i18n_store.with(content) do
      locale = options.delete('locale')

      key = input
      scope = nil

      if key.start_with?('.')
        key = input[1..-1]
        scope = content.translation_scope
      end

      result = I18n.t(key, options, locale: locale, scope: scope, cascade: { skip_root: false })
    end

    result
  end
  alias_method :t, :translate
end

Liquid::Template.register_filter(TranslateFilter)
