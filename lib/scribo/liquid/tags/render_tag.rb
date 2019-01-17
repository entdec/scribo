# frozen_string_literal: true

# Render content from variable
#
# == Basic usage:
#    {%render product.description}
#
class RenderTag < ScriboTag
  def render(context)
    var = lookup(context, @argv1)
    return unless var

    template = Liquid::Template.parse(var)
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('render', RenderTag)
