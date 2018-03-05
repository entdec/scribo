# frozen_string_literal: true

# Include tag, includes content by identifier
#
# {% include 'navigation' %}
class IncludeTag < Liquid::Tag
  SYNTAX = /(#{Liquid::QuotedFragment})/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ SYNTAX
      @identifier = Liquid::Expression.parse(Regexp.last_match[1])
    else
      raise SyntaxError, "Syntax Error in 'include' - Valid syntax: include 'identifier'"
    end
  end

  # Lookup allows access to the page/post variables through the tag context
  def lookup(context, name)
    lookup = context
    name.split('.').each { |value| lookup = lookup[value] }
    lookup
  end

  def render(context)
    current_content = lookup(context.registers, 'content')

    content = current_content.site.contents.identified(@identifier).first
    content&.render(context, context.registers)
  end
end

Liquid::Template.register_tag('include', IncludeTag)
