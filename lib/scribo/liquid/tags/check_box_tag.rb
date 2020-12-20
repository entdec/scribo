# frozen_string_literal: true

# Add a check-box, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%check_box name:"name" value:"1"%}
#
# == Advanced usage:
#    {%check_box name%}
#
# This last usage requires a model on the form
#
class CheckBoxTag < LiquorTag
  def render(context)
    super

    if @form_model
      %[<input ] + attr_str(:name, arg(:name),
                            input(:name, argv1)) + %[value="0" type="hidden"/>]
    else

      %[<input ] + attr_str(:name, arg(:name), input(:name, argv1)) +
        attr_str(:id, arg(:id), input(:id, argv1)) +
        attr_str(:value, arg(:value), input(:value, argv1) ? 1 : 0) +
        attr_str(:checked, arg(:checked), input(:checked, argv1)) +
        attrs_str(:disabled, :maxlength, :placeholder, :class) + %[ type="checkbox"/>]
    end
  end
end

Liquid::Template.register_tag('check_box', CheckBoxTag)
