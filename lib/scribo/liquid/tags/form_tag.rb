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

class FormTag < ScriboBlock
  def render(context)
    result = %[<form] + attribute(context, :action, @args[:action]) + %[>]
    context.stack do
      context['form_model'] = lookup(context, @argv1)
      context['form'] = FormDrop.new(lookup(context, @argv1))
      result += super
    end
    result += %[</form>]
    result
  end
end

Liquid::Template.register_tag('form', FormTag)
