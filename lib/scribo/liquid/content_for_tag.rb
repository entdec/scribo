# frozen_string_literal: true

# Stores content for a section
#
# {% content_for 'sidebar' %}
# {% endcontent_for %}
class ContentForTag < Liquid::Block
  SYNTAX = /(#{Liquid::QuotedFragment})/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ SYNTAX
      @to = Liquid::Expression.parse(Regexp.last_match[1])
    else
      raise SyntaxError, "Syntax Error in 'content_for' - Valid syntax: content_for 'name'"
    end
  end

  def render(context)
    output                           = super
    context.registers['_yield']      = {} unless context.registers['_yield']
    context.registers['_yield'][@to] = output
    ''
  end
end

Liquid::Template.register_tag('content_for', ContentForTag)
