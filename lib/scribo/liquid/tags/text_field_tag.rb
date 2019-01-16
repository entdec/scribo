# frozen_string_literal: true

# text field
#
# {% text_field name %}
class TextFieldTag < ScriboTag
  def render(context)
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    %[<input] + attribute(context, :name, @args[:name], input(:name, @argv1)) +
      attribute(context, :id, @args[:id], input(:id, @argv1)) +
      attribute(context, :value, @args[:value], input(:value, @argv1)) +
      attributes(context, :disabled, :maxlength, :placeholder) + %[>]
  end
end

Liquid::Template.register_tag('text_field', TextFieldTag)
