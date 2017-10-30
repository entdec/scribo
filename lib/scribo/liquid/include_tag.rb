# frozen_string_literal: true

# Include tag, includes content by identifier
#
# {% include 'navigation' %}
class IncludeTag < Liquid::Tag
  Syntax = /(#{Liquid::QuotedFragment})/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ Syntax
      @identifier = Liquid::Expression.parse(Regexp.last_match[1])
    else
      raise SyntaxError, "Syntax Error in 'include' - Valid syntax: include 'identifier'"
    end
  end

  def render(_context)
    content = Scribo::Content.identified(@identifier).first
    content.render if content
  end
end

Liquid::Template.register_tag('include', IncludeTag)
