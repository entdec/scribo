# frozen_string_literal: true

require_relative './liquid_helpers'

# button
#
# {%button type%}text{%endbutton%}
#
# example:
# {%button button|reset|submit%}Save{%endbutton%}
#
class ButtonTag < Liquid::Block
  include Scribo::LiquidHelpers

  def render(context)
    @form_model = context.find_variable('form_model')
    %[<button #{attr_str(:type, @args[:argv1], 'submit')}#{attr_str(:name, @args[:name], 'commit')}#{attr_str(:value, @args[:value])}>#{super(context)}</button>]
  end
end

Liquid::Template.register_tag('button', ButtonTag)
