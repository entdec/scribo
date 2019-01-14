# frozen_string_literal: true

require_relative './liquid_helpers'

# text field
#
# {% text_field name %}
class TextFieldTag < Liquid::Tag
  include Scribo::LiquidHelpers

  def render(context)
    @form_model = context.find_variable('form_model')

    value = @form_model.send(@args[:argv1].to_sym) if @form_model && @args[:argv1]
    name = "#{@form_model.class.name.tr('Drop', '').underscore}[#{@args[:argv1]}]" if @form_model && @args[:argv1]

    %[<input#{attr_str(:name, @args[:name], name)}#{attr_str(:value, @args[:value], value)}>]
  end
end

Liquid::Template.register_tag('text_field', TextFieldTag)
