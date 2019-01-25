# frozen_string_literal: true

# Makes content available to be used elsewhere
#
# == Basic usage:
#    {%content_for 'sidebar'%}
#    Test
#    {%endcontent_for%}
#
# The content in the block will be available to the yield tag
#
class ContentForTag < ScriboBlock
  def render(context)
    super

    output = render_body
    context.registers['_yield'] = {} unless context.registers['_yield']
    context.registers['_yield'][argv1] = output
    ''
  end
end

Liquid::Template.register_tag('content_for', ContentForTag)
