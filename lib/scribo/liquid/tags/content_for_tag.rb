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
class ContentForTag < LiquorBlock
  def render(context)
    super

    context.registers['_yield'] ||= {}
    context.registers['_yield'][argv1] = render_body
    ''
  end
end

Liquid::Template.register_tag('content_for', ContentForTag)
