# frozen_string_literal: true

# Yields content
#
# {% yield %}
# {% yield 'sidebar' %}
class YieldTag < Liquid::Tag
  SYNTAX = /(#{Liquid::QuotedFragment})?/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ SYNTAX
      @name = Liquid::Expression.parse(Regexp.last_match[1]).to_s
    else
      raise SyntaxError, "Syntax Error in 'yield' - Valid syntax: yield ['name']"
    end
  end

  # Lookup allows access to the page/post variables through the tag context
  def lookup(context, name)
    lookup = context
    name.split('.').each { |value| lookup = lookup[value] }
    lookup
  end

  def render(context)
    yield_content = lookup(context, '_yield')
    yield_content&.[](@name)&.to_s
  end
end

Liquid::Template.register_tag('yield', YieldTag)
