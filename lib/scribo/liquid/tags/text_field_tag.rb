# frozen_string_literal: true

# text field
#
# {% text_field name %}
class TextFieldTag < ScriboTag
  def render(context)
    @form_model = lookup(context, 'form_model')

    %[<input] + attr_str(context, :name, @args[:name], input_name(@form_model, @argv1)) +
      attr_str(context, :value, @args[:value], input_value(@form_model, @argv1)) + %[>]
  end

  def input_name(form_model, name)
    return unless form_model && name

    "#{form_model.class.name.tr('Drop', '').underscore}[#{name}]"
  end

  def input_value(form_model, name)
    return unless form_model && name

    form_model.send(name.to_sym) if form_model && name
  end
end

Liquid::Template.register_tag('text_field', TextFieldTag)