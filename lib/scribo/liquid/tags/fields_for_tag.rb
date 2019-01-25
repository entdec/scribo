# frozen_string_literal: true

# Exposes additional model objects, similar to form, but it doesn't create a form-tag.
#
# == Basic usage:
#    {%fields_for location%}
#      {%text_field city%}
#    {%endform%}
#
# == Available variables:
#
# form.model:: model specified
# form.class_name:: class name of the model specified (original name, not the drop)
# form.errors:: errors of the exposed object
#
require_relative '../drops/form_drop'

class FieldsForTag < ScriboBlock
  def render(context)
    super

    result = ''

    new_model = lookup(context['form.model'], argv1)
    context.stack do
      context['form'] = FormDrop.new(new_model, argv1)
      result += render_body
    end
    result
  end
end

Liquid::Template.register_tag('fields_for', FieldsForTag)
