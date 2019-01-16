# frozen_string_literal: true

# text field
#
# {% label name %}
class LabelTag < ScriboBlock
  def render(context)
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    %[<label] + attribute(context, :for, @args[:for], input(:id, @argv1)) + %[>] + super + %[</label>]
  end
end

Liquid::Template.register_tag('label', LabelTag)
