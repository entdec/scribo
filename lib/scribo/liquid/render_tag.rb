# frozen_string_literal: true

# Renders content
#
# {% render name%}
class RenderTag < Liquid::Tag
  Syntax = /(#{Liquid::VariableSignature}+)/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ SYNTAX
      @name = Liquid::Expression.parse(Regexp.last_match[1]).to_s
    else
      raise SyntaxError, "Syntax Error in 'render' - Valid syntax: render name"
    end
  end

  # Lookup allows access to the page/post variables through the tag context
  def lookup(context, name)
    lookup = context
    name.split('.').each { |value| lookup = lookup[value] }
    lookup
  end

  def render(context)
    template = Liquid::Template.parse(lookup(context, @name))
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('blablablarender', RenderTag)
