# frozen_string_literal: true

# Add a text_field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%label for="name"%}Name:{%endlabel%}
#
# == Advanced usage:
#    {%label name%}Name:{%endlabel%}
#
# This last usage requires a model on the form
#
class LabelTag < ScriboBlock
  def render(context)
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    %[<label] + attribute(context, :for, @args[:for], input(:id, @argv1)) + %[>] + super + %[</label>]
  end
end

Liquid::Template.register_tag('label', LabelTag)
