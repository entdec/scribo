# frozen_string_literal: true

# Add a check-box, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%check_box name="name" value="1"%}
#
# == Advanced usage:
#    {%check_box name%}
#
# This last usage requires a model on the form
#
class CheckBoxTag < ScriboTag
  def render(context)
    super

    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    result = []
    result << %[<input] + attr_str(:name, named_attr(context, :name), input(:name, argv1(context))) + %[value="0" type="hidden"/>] if @form_model
    result << %[<input] + attr_str(:name, named_attr(context, :name), input(:name, argv1(context))) +
              attr_str(:id, named_attr(context, :id), input(:id, argv1(context))) +
              attr_str(:value, named_attr(context, :value), input(:value, argv1(context)) ? 1 : 0) +
              attr_str(:checked, named_attr(context, :checked), input(:checked, argv1(context))) +
              attributes(context, :disabled, :maxlength, :placeholder) + %[ type="checkbox"/>]
  end
end

Liquid::Template.register_tag('check_box', CheckBoxTag)
