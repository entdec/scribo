# frozen_string_literal: true

# Include tag, includes content by identifier, passes variables/values to the included template
#
# {% include 'navigation' title="Test"%}
class IncludeTag < Liquid::Tag
  SYNTAX = /(\"|\')(?<identifier>[^\"\']+)(\"|\')\s?(?<attrs>((([a-z_]+)\=\"([^\"]*)\")\s?)*)/o

  def initialize(tag_name, markup, options)
    super
    if markup =~ SYNTAX
      @identifier = Regexp.last_match[:identifier]

      attr_re = /(?<name>\b\w+\b)\s*=\s*("(?<value>[^"]*)"|'(?<value>[^']*)'|(?<value>[^"'<> \s]+)\s*)+/

      attrs = Regexp.last_match[:attrs]

      @assigns = {}
      attrs.scan(attr_re).collect do |match|
        @assigns[match[0]] = match[1]
      end
    else
      raise SyntaxError, "Syntax Error in 'include' - Valid syntax: include 'identifier'"
    end
  end

  def render(context)
    current_content = context.registers['content']

    content = current_content.site.contents.identified(@identifier).first
    content&.render(context.merge(@assigns), context.registers)
  end
end

Liquid::Template.register_tag('include', IncludeTag)
