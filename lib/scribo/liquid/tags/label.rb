# frozen_string_literal: true

# text field
#
# {% label name %}
class LabelTag < ScriboBlock
  def render(context)
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    %[<label] + attribute(context, :for, @args[:for], input_id(@form_model, @argv1)) + %[>] + super + %[</label>]
  end

  def input_id(form_model, name)
    return unless form_model && name

    "#{@form_class_name.underscore}_#{name}"
  end
end

Liquid::Template.register_tag('label', LabelTag)
