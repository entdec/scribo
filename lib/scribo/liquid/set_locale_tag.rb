# frozen_string_literal: true

# Sets the I18n.locale
#
# {%set_locale variable%}
class SetLocaleTag < Liquid::Tag
  def initialize(tag_name, markup, options)
    super
    @name = markup.strip
  end

  def render(context)
    value = Liquid::VariableLookup.parse(@name).evaluate(context)
    I18n.locale = value.to_sym
    context.registers['controller'].session[:locale] = I18n.locale
    nil
  end
end

Liquid::Template.register_tag('set_locale', SetLocaleTag)
