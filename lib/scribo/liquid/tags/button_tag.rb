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
    %[<button] + attribute(context, :type, @argv1, 'submit') +
      attribute(context, :name, @args[:name], 'commit') +
      attribute(context, :value, @args[:value]) +
      %[>] + super(context) + %[</button>]
  end
end

Liquid::Template.register_tag('button', ButtonTag)
