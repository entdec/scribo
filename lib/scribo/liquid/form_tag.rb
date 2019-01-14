# frozen_string_literal: true

require_relative './liquid_helpers'

# Allows you to add forms to your pages
#
# {% form channel action="/admin/channels"%}
# {% endform %}
class FormTag < Liquid::Block
  include Scribo::LiquidHelpers

  def render(context)
    @form_model = context.find_variable(@args[:argv1])

    result = %[<form#{attr_str(:action, @args[:action])}>]
    context.stack do
      context['form_model'] = @form_model
      result += super
    end
    result += %[</form>]
    result
  end
end

Liquid::Template.register_tag('form', FormTag)
