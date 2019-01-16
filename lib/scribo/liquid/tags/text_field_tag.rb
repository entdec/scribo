# frozen_string_literal: true

# text field
#
# {% text_field name %}
class TextFieldTag < ScriboTag
  def render(context)
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    %[<input] + attribute(context, :name, @args[:name], input_name(@form_model, @argv1)) +
      attribute(context, :id, @args[:id], input_id(@form_model, @argv1)) +
      attribute(context, :value, @args[:value], input_value(@form_model, @argv1)) +
      attributes(context, :disabled, :maxlength, :placeholder) + %[>]
  end

  def input_name(form_model, name)
    return unless form_model && name

    # The original class's name dictates the name of the fields
    "#{@form_class_name.underscore}[#{name}]"
  end

  def input_value(form_model, name)
    return unless form_model && name

    # This is executed on the drop, drops provide the values for the form
    form_model.send(name.to_sym) if form_model && name
    end

  def input_id(form_model, name)
    return unless form_model && name

    "#{@form_class_name.underscore}_#{name}"
  end
end

Liquid::Template.register_tag('text_field', TextFieldTag)
