# frozen_string_literal: true

# Adds a (by default submit) button
#
# == Basic usage:
#    {%select name:'group'%}{%endselect%}
#
# == Advanced usage:
#    {%select group%}{%endselect%}
#
class SelectTag < LiquorBlock
  def render(context)
    super

    result = %[<select] + attr_str(:name, arg(:name), input(:name, argv1)) +
      attr_str(:id, arg(:id), input(:id, argv1)) +
      attrs_str(reject: %[name id]) +
      %[>] + render_body + %[</select>]

    result
  end
end

Liquid::Template.register_tag('select', SelectTag)
