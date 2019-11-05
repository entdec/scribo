# frozen_string_literal: true

# Add a text-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%text_field name:"name" value:"Pencil"%}
#
# == Advanced usage:
#    {%text_field name%}
#
# This last usage requires a model on the form
#
class TextareaTag < LiquorTag
  def initialize(tag, args, tokens)
    super
  end

  def render(context)
    super

    result = %[<textarea] +
             attr_str(:name, arg(:name), input(:name, argv1)) +
             attr_str(:id, arg(:id), input(:id, argv1))

    result += attrs_str(reject: %[name value id])
    result += %[ />]
    result += (arg(:value) || input(:value, argv1)).to_s
    result += %[</textarea>]
    result
  end
end

Liquid::Template.register_tag('textarea', TextareaTag)
