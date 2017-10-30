# frozen_string_literal: true

# Stores content for a section
#
# {% content_for 'sidebar' %}
# {% endcontent_for %}
class ContentForTag < Liquid::Block
  Syntax = /(#{Liquid::QuotedFragment})/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ Syntax
      @to = Liquid::Expression.parse(Regexp.last_match[1])
    else
      raise SyntaxError, "Syntax Error in 'content_for' - Valid syntax: content_for 'name'"
    end
  end

  def render(context)
    output                                    = super
    context.environments.first['_yield']      = {} unless context.environments.first['_yield']
    context.environments.first['_yield'][@to] = output
    ''
  end
end

Liquid::Template.register_tag('content_for', ContentForTag)
