# frozen_string_literal: true

# Add a text-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%text_field name="name" value="Pencil"%}
#
# == Advanced usage:
#    {%text_field name%}
#
# This last usage requires a model on the form
#
class TextFieldTag < ScriboTag
  def render(context)
    super

    %[<input] + attr_str(:name, arg(:name), input(:name, argv1)) +
      attr_str(:id, arg(:id), input(:id, argv1)) +
      attr_str(:value, arg(:value), input(:value, argv1)) +
      attrs_str(:disabled, :maxlength, :placeholder) + %[ type="text"/>]
  end
end

Liquid::Template.register_tag('text_field', TextFieldTag)
