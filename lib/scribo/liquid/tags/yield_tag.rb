# frozen_string_literal: true

# Makes content available to be used elsewhere
#
# == Basic usage:
#    {%yield%}
#    {%yield 'sidebar'%}
class YieldTag < ScriboTag
  def render(context)
    yield_content = lookup(context.registers, '_yield')
    yield_content&.[](@argv1.to_s)&.to_s
  end
end

Liquid::Template.register_tag('yield', YieldTag)
