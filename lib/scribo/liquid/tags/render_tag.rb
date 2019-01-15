# frozen_string_literal: true

# Renders content
#
# {%render variable%}
class RenderTag < Liquid::Tag
  def initialize(tag_name, markup, options)
    super
    @name = markup.strip
  end

  def render(context)
    value = Liquid::VariableLookup.parse(@name).evaluate(context)
    template = Liquid::Template.parse(value)
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('render', RenderTag)
