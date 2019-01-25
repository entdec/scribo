# frozen_string_literal: true

# Adds a (by default submit) button
#
# == Basic usage:
#    {%button name='commit' value='save'%}Save{%endbutton%}
#
# == Advanced usage:
#    {%button button name='commit' value='save'%}Save{%endbutton%}
#    {%button reset name='commit' value='save'%}Save{%endbutton%}
#
class ButtonTag < ScriboBlock
  def render(context)
    super

    %[<button] + attr_str(:type, argv1, 'submit') +
      attr_str(:name, arg(:name), 'commit') +
      attr_str(:value, arg(:value)) +
      attr_str(:class, arg(:class)) +
      %[>] + render_body + %[</button>]
  end
end

Liquid::Template.register_tag('button', ButtonTag)
