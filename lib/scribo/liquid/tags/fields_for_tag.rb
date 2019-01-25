# frozen_string_literal: true

# Form adds a form tag, when you specify a model it will use and expose that to nested fields.
# Exposing a model will ease the creation of nested fields.
#
# == Basic usage:
#    {%form%}
#      {%text_field name="name" value="Pencil"%}
#    {%endform%}
#
# == Advanced usage:
#    {%form product%}
#      {%text_field name%}
#    {%endform%}
#
# == Available variables:
#
# form.model:: model specified
# form.class_name:: class name of the model specified (original name, not the drop)
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
