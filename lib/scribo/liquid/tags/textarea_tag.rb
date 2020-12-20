# frozen_string_literal: true

# Add a text-area, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%textarea name:"name"%}{%endtextarea%}
#
# == Advanced usage:
#    {%textarea name%}{%endtextarea%}
#
# This last usage requires a model on the form
#
class TextareaTag < LiquorBlock
  def render(context)
    super

    result = %[<textarea] +
             attr_str(:name, arg(:name), input(:name, argv1)) +
             attr_str(:id, arg(:id), input(:id, argv1))

    result += attrs_str(reject: %[name id])
    result += %[>] + render_body + %[</textarea>]

    result
  end
end

Liquid::Template.register_tag('textarea', TextareaTag)
