# frozen_string_literal: true

# Render content from variable
#
# == Basic usage:
#    {%render product.description}
#
class RenderTag < ScriboTag
  def render(context)
    super

    return unless argv1

    template = Liquid::Template.parse(argv1)
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('render', RenderTag)
