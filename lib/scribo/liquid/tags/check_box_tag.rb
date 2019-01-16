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
    @form_model = lookup(context, 'form.model')
    @form_class_name = lookup(context, 'form.class_name')

    result = []
    result << %[<input] + attribute(context, :name, @args[:name], input(:name, @argv1)) + %[value="0" type="hidden"/>] if @form_model
    result << %[<input] + attribute(context, :name, @args[:name], input(:name, @argv1)) +
              attribute(context, :id, @args[:id], input(:id, @argv1)) +
              attribute(context, :value, @args[:value], input(:value, @argv1) ? 1 : 0) +
              attribute(context, :checked, @args[:checked], input(:checked, @argv1)) +
              attributes(context, :disabled, :maxlength, :placeholder) + %[ type="checkbox"/>]
  end
end

Liquid::Template.register_tag('check_box', CheckBoxTag)
