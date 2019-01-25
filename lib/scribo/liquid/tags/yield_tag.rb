# frozen_string_literal: true

# Makes content available to be used elsewhere
#
# == Basic usage:
#    {%yield%}
#    {%yield 'sidebar'%}
class YieldTag < ScriboTag
  def render(context)
    super

    yield_content = lookup(context.registers, '_yield')
    return unless yield_content

    yield_content&.[](argv1.to_s)&.to_s
  end
end

Liquid::Template.register_tag('yield', YieldTag)
