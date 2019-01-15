# frozen_string_literal: true

# Render content from variable
#
# == Basic usage:
#    {%render product.description}
#
class RenderTag < ScriboTag
  def render(context)
    template = Liquid::Template.parse(lookup(context, @argv1))
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('render', RenderTag)
