# frozen_string_literal: true

# Form adds a form tag, when you specify a model it will use and expose that to nested fields.
# Exposing a model will ease the creation of nested fields.
#
# == Basic usage:
#    {%form%}
#      {%text_field name:"name" value:"Pencil"%}
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
# form.errors:: errors of the exposed object
#
# require_relative '../drops/form_drop'

class FormTag < LiquidumBlock
  def render(context)
    super

    method = arg(:method).to_s.downcase
    method = argv1.instance_variable_get('@object').persisted? ? 'patch' : 'post' if method.blank? && argv1

    rails_method = nil
    if %w[get post].exclude? method
      rails_method = method
      method       = 'post'
    end

    result = %[<form] +
             attr_str(:action, arg(:action)) +
             attr_str(:method, method) +
             attrs_str(reject: %[action method]) +
             %[>]

    if context.registers['controller']
      result += %[<input name="_method" type="hidden" value="#{rails_method}"/>] if rails_method
      result += %[<input name="authenticity_token" type="hidden" value="#{context.registers['controller'].helpers.form_authenticity_token}"/>]
    end

    context.stack do
      context['form'] = Scribo::FormDrop.new(argv1)
      result += render_body
    end
    result += %[</form>]
    result
  end
end

Liquid::Template.register_tag('form', FormTag)
